;(function (exports) {

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

})(this);