;(function (exports,libA,libB) {

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

})(this,void 0, require("lib-b-cjs"));