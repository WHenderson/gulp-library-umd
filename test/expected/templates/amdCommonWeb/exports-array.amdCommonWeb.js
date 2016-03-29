// Taken from gulp-umd
;(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    
    define(["exports"], factory);
  } else if (typeof exports === 'object') {
    
    factory(exports);
  } else {
    // Browser globals
    
    factory((root.exportsArray = {}));
  }
}(this, function (exports) {

  (function (results) {
    
    
    exports.my1stExport = results.my1stExport;
    exports.my2ndExport = results.my2ndExport;
    
  })((function () {
  var exports = function () {
    return 'js module';
  };
  return {  my1stExport: my1stExport, my2ndExport: my2ndExport };
})());

}));