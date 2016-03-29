// Taken from gulp-umd
;(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    
    define(["exports","lib-b-amd"], function (exports, libB) { factory(exports, void 0,libB); });
  } else if (typeof exports === 'object') {
    
    factory(exports,void 0, require("lib-b-cjs"));
  } else {
    // Browser globals
    
    factory((root.distinctLibs = {}),void 0, root.libBWeb);
  }
}(this, function (exports,libA,libB) {

  (function (results) {
    
    for (var key in results) {
      if ({}.hasOwnProperty.call(results, key))
        exports[key] = results[key];
    }
    
  })((function (libA,libB) {
  var exports = function () {
    return 'js module';
  };
  return exports;
})(libA,libB));

}));