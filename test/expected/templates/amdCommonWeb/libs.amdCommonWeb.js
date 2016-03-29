// Taken from gulp-umd
;(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    
    define(["exports","lib-a","lib-b","lib-c"], factory);
  } else if (typeof exports === 'object') {
    
    factory(exports,require("lib-a"), require("lib-b"), require("lib-c"));
  } else {
    // Browser globals
    
    factory((root.libs = {}),root.lib-a, root.lib-b, root.lib-c);
  }
}(this, function (exports,libA,libB,libC) {

  (function (results) {
    
    for (var key in results) {
      if ({}.hasOwnProperty.call(results, key))
        exports[key] = results[key];
    }
    
  })((function (libA,libB,libC) {
  var exports = function () {
    return 'js module';
  };
  return exports;
})(libA,libB,libC));

}));