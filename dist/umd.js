var MAGIC, defaultOptions, dot, es, extend, fs, gutil, path, templateSettings, wrap,
  hasProp = {}.hasOwnProperty;

dot = require('dot');

path = require('path');

fs = require('fs');

extend = require('extend');

gutil = require('gulp-util');

es = require('event-stream');

defaultOptions = {
  templateCache: true,
  templateName: 'amd.dot',
  modes: ['cjs', 'amd', 'global', 'default']
};

MAGIC = '46e50563-66cc-4cd3-8dcf-46c527554f54';

templateSettings = extend({}, dot.templateSettings, {
  strip: false
});

wrap = function(file, options, cb) {
  var arg, i, it, len, lib, mode, ref, ref1, ref2, ref3, render;
  it = {
    options: options,
    file: file,
    jsonify: function(data) {
      return JSON.stringify(data);
    }
  };
  if (options.require == null) {
    options.require = {};
  }
  ref1 = (ref = options.modes) != null ? ref : [];
  for (i = 0, len = ref1.length; i < len; i++) {
    mode = ref1[i];
    options[mode] = {
      require: {},
      args: [],
      libs: [],
      exports: options.exports,
      namespace: options.namespace
    };
    ref2 = options.require;
    for (arg in ref2) {
      if (!hasProp.call(ref2, arg)) continue;
      lib = ref2[arg];
      options[mode].require[arg] = typeof lib === 'string' ? lib : (ref3 = lib[mode]) != null ? ref3 : lib.name;
    }
    options[mode].args = Object.keys(options[mode].require);
    options[mode].libs = Object.keys(options[mode].require).map(function(k) {
      return options[mode].require[k];
    });
  }
  render = function() {
    var final;
    it.options.trueContents = contents;
    it.options.contents = MAGIC;
    final = it.options.template(it);
    final = final.replace(/^(.*?)$/gm, function(match, line) {
      return line.replace(new RegExp('(^\\s*)?' + MAGIC), function(match, indent, magic) {
        return it.options.trueContents.replace(/^/gm, indent);
      });
    });
    return new Buffer(final);
  };
  if (gutil.isStream(file.contents)) {
    es.wait(function(err, contents) {
      it.contents = contents;
      debugger;
      file.contents = render();
      cb(null, file);
    });
  } else {
    it.contents = file.contents;
    debugger;
    file.contents = render();
    cb(null, file);
  }
};

module.exports = function(overrides) {
  var cache;
  overrides = extend(true, {}, defaultOptions, overrides);
  cache = {};
  return es.map(function(file, cb) {
    var name, options;
    options = extend(true, {}, file.data, overrides);
    name = path.basename(file.path, path.extname(file.path)).replace(/(?:\W|_)+(\w)/g, function(match, ch) {
      return ch.toUpperCase();
    }).replace(/\W/g, '');
    if (options.exports == null) {
      options.exports = name;
    }
    if (options.namespace == null) {
      options.namespace = name;
    }
    if ((options.templateName != null) && (options.templatePath == null)) {
      options.templatePath = path.join(__dirname, '../templates', options.templateName);
    }
    if (options.templatePath != null) {
      if (options.templateCache && (cache[options.templatePath] != null)) {
        options.template = cache[options.templatePath];
      } else {
        fs.readFile(options.templatePath, 'utf8', function(err, data) {
          var template;
          if (err != null) {
            return cb(err);
          }
          template = dot.template(data, templateSettings);
          if (options.templateCache) {
            cache[template] = template;
          }
          options.template = template;
          return wrap(file, options, cb);
        });
      }
    } else {
      if (typeof options.template === 'string') {
        options.template = dot.template(options.template, templateSettings);
      }
      wrap(file, options, cb);
    }
  });
};
