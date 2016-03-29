;(function (exports,libA,libB,libC) {

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

})(this,require("lib-a"), require("lib-b"), require("lib-c"));