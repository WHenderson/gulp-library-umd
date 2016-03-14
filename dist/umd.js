var defaultOptions, dot, es, extend, fs, gutil, path, wrap;

dot = require('dot');

path = require('path');

fs = require('fs');

extend = require('extend');

gutil = require('gulp-util');

es = require('event-stream');

defaultOptions = {
  templateCache: true,
  templateName: 'umd.dot'
};

wrap = function(file, options, cb) {
  var it;
  it = {
    options: options,
    file: file,
    jsonify: function(data) {
      return JSON.stringify(data);
    }
  };
  if (gutil.isStream(file.contents)) {
    es.wait(function(err, contents) {
      it.contents = contents;
      file.contents = new Buffer(it.options.template(it));
      cb();
    });
  } else {
    file.contents = new Buffer(it.options.template(it));
    cb();
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
          template = dot.template(data);
          if (options.templateCache) {
            cache[template] = template;
          }
          options.template = template;
          return wrap(file, options, cb);
        });
      }
    } else {
      if (typeof options.template === 'string') {
        options.template = dot.template(options.template);
      }
      wrap(file, options, cb);
    }
  });
};
