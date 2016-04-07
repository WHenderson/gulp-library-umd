var compile, defaultOptions, dot, es, extend, fs, gutil, namespace, path, pipe, rename, render, templatesBase, wrap,
  hasProp = {}.hasOwnProperty;

dot = require('dot');

path = require('path');

fs = require('fs');

extend = require('extend');

gutil = require('gulp-util');

es = require('event-stream');

defaultOptions = {
  templateCache: true,
  templateName: void 0,
  templatePath: void 0,
  template: void 0,
  modes: ['cjs', 'node', 'amd', 'web'],
  indent: true,
  rename: true,
  require: {},
  exports: 'exports',
  namespace: void 0
};

templatesBase = path.join(__dirname, '../templates');

compile = function(templateSource) {
  return dot.template(templateSource, compile.settings, compile.defines);
};

compile.settings = extend({}, dot.templateSettings, {
  strip: false
});

compile.defines = (function() {
  var defines, ext, i, len, name, ref, source;
  defines = {};
  ref = fs.readdirSync(path.join(__dirname, '../templates/def')).sort();
  for (i = 0, len = ref.length; i < len; i++) {
    source = ref[i];
    if (path.extname(source) === '.def') {
      name = path.basename(source, path.extname(source));
      ext = path.extname(name);
      if (ext !== '') {
        name = path.basename(name, ext) + ext[1].toUpperCase() + ext.slice(2);
      }
      defines[name] = fs.readFileSync(path.join(__dirname, '../templates/def', source));
    }
  }
  return defines;
})();

namespace = function(filePath) {
  return path.basename(filePath, path.extname(filePath)).replace(/(?:\W|_)+(\w)/g, function(match, ch) {
    return ch.toUpperCase();
  }).replace(/\W/g, '');
};

render = function(file, it, contents) {
  var MAGIC, applySourceMap, consumer, contentLineCount, generator, iline, offsetLine, output, sourceMap;
  MAGIC = '(void "46e50563-66cc-4cd3-8dcf-46c527554f54")';
  contents = contents.toString();
  it.trueContents = contents;
  it.contents = MAGIC;
  output = it.options.template(it).replace(/\r\n|\n/g, '\n');
  if (file.sourceMap != null) {
    sourceMap = require('source-map');
    applySourceMap = require('vinyl-sourcemaps-apply');
    generator = new sourceMap.SourceMapGenerator(file.sourceMap);
    consumer = new sourceMap.SourceMapConsumer(file.sourceMap);
    contentLineCount = contents.split('\n').length - 1;
    if (file.sourceMap.mappings.length === 0) {
      iline = 0;
      while (iline !== contentLineCount + 1) {
        generator.addMapping({
          generated: {
            line: iline + 1,
            column: 0
          },
          original: {
            line: iline + 1,
            column: 0
          },
          source: file.sourceMap.sources[0],
          name: null
        });
        ++iline;
      }
      applySourceMap(file, generator.toString());
      generator = new sourceMap.SourceMapGenerator(file.sourceMap);
      consumer = new sourceMap.SourceMapConsumer(file.sourceMap);
    }
  }
  offsetLine = 0;
  output = output.split(/\r\n|\n/).map(function(line, iline) {
    return line.replace(new RegExp('^([ \t]*)' + MAGIC.replace(/\(/g, '\\(').replace(/\)/g, '\\)\s*$'), 'gm'), function(match, indent) {
      var icolumn, rendered;
      if (indent == null) {
        indent = '';
      }
      if (it.options.indent && indent.length !== 0) {
        rendered = indent + contents.replace(/\r\n|\n/g, '\n' + indent);
      } else {
        indent = '';
        rendered = contents;
      }
      icolumn = indent.length;
      if (file.sourceMap != null) {
        consumer.eachMapping(function(mapping) {
          return generator.addMapping({
            generated: {
              line: mapping.generatedLine + iline + offsetLine,
              column: mapping.generatedColumn + indent.length
            },
            original: {
              line: mapping.originalLine,
              column: mapping.originalColumn
            },
            source: mapping.source,
            name: mapping.name
          });
        });
        offsetLine += contentLineCount;
      }
      return rendered;
    });
  }).join('\n');
  file.contents = new Buffer(output);
  if (file.sourceMap != null) {
    applySourceMap(file, generator.toString());
  }
};

rename = function(file, options) {
  var ext, name;
  if (options.rename && ((options.templateName != null) || (options.templatePath != null))) {
    ext = path.extname(options.templatePath);
    name = path.basename(options.templatePath, ext);
    if (name.charAt(0) === '.') {
      name = name.slice(1);
    }
    if (ext === '.dot' || ext === '.def') {
      ext = path.extname(name);
      name = path.basename(name, ext);
    }
    if ((ext == null) || ext === '') {
      ext = path.extname(file.basename);
    }
    file.basename = path.basename(file.basename, path.extname(file.basename)) + '.' + name.replace(/\\\//g, '-') + ext;
  }
};

wrap = function(file, options, cb) {
  var arg, i, it, j, len, len1, lib, mode, modes, ref, ref1, ref2, ref3;
  it = {
    options: options,
    mode: {},
    factory: {
      args: Object.keys(options.require)
    }
  };
  modes = ((ref = options.modes) != null ? ref : []).slice();
  ref1 = options.require;
  for (arg in ref1) {
    if (!hasProp.call(ref1, arg)) continue;
    lib = ref1[arg];
    if (typeof lib !== 'string') {
      ref2 = Object.keys(lib);
      for (i = 0, len = ref2.length; i < len; i++) {
        mode = ref2[i];
        if (mode !== 'name' && modes.indexOf(mode) === -1) {
          modes.push(mode);
        }
      }
    }
  }
  for (j = 0, len1 = modes.length; j < len1; j++) {
    mode = modes[j];
    it.mode[mode] = {
      require: {},
      requireArray: [],
      args: [],
      libs: [],
      libStrings: [],
      factoryArgs: []
    };
    ref3 = options.require;
    for (arg in ref3) {
      if (!hasProp.call(ref3, arg)) continue;
      lib = ref3[arg];
      lib = typeof lib === 'string' ? lib : (lib[mode] !== void 0 ? lib[mode] : lib.name);
      if (lib != null) {
        it.mode[mode].require[arg] = lib;
        it.mode[mode].requireArray.push({
          arg: arg,
          lib: lib,
          libString: JSON.stringify(lib)
        });
        it.mode[mode].args.push(arg);
        it.mode[mode].libs.push(lib);
        it.mode[mode].libStrings.push(JSON.stringify(lib));
      }
      it.mode[mode].factoryArgs.push(lib != null ? arg : 'void 0');
    }
  }
  if (gutil.isStream(file.contents)) {
    file.contents.pipe(es.wait(function(err, contents) {

      /* !pragma coverage-skip-next */
      if (err != null) {
        return cb(err);
      }
      render(file, it, contents);
      rename(file, options);
      cb(null, file);
    }));
  } else {
    render(file, it, file.contents);
    rename(file, options);
    cb(null, file);
  }
};

pipe = function(overrides) {
  var cache;
  overrides = extend(true, {}, defaultOptions, overrides);
  cache = {};
  return es.map(function(file, cb) {
    var options;
    options = extend(true, {}, file.data, overrides);
    if (options.namespace == null) {
      options.namespace = namespace(file.path);
    }
    if ((options.templateName != null) && (options.templatePath == null)) {
      if (path.extname(options.templateName) === '') {
        options.templateName += path.extname(file.path);
      }
      if (path.extname(options.templateName) !== '.dot') {
        options.templateName += '.dot';
      }
      options.templatePath = path.join(templatesBase, options.templateName);
    }
    if (options.templatePath != null) {
      if (options.templateCache && (cache[options.templatePath] != null)) {
        options.template = cache[options.templatePath];
      } else {
        fs.readFile(options.templatePath, function(err, data) {
          var template;
          if (err != null) {
            return cb(err);
          }
          template = compile(data);
          if (options.templateCache) {
            cache[options.templatePath] = template;
          }
          options.template = template;
          return wrap(file, options, cb);
        });
        return;
      }
    }
    if (options.template != null) {
      if (typeof options.template === 'string') {
        options.template = compile(options.template);
      }
      wrap(file, options, cb);
      return;
    }
    throw new Error('No template specified');
  });
};

module.exports = pipe;
