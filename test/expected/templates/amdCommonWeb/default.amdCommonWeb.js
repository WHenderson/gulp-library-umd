// Taken from gulp-umd
;(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    
    define(["exports"], factory);
  } else if (typeof exports === 'object') {
    
    factory(exports);
  } else {
    // Browser globals
    
    factory((root.default = {}));
  }
}(this, function (exports) {

  (function (results) {
    
    for (var key in results) {
      if ({}.hasOwnProperty.call(results, key))
        exports[key] = results[key];
    }
    
  })((function () {
  var exports = function () {
    return 'js module';
  };
  return exports;
})());

}));