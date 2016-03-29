;(function (exports) {

  (function (results) {
    
    
    exports.my1stExport = results.my1stExport;
    exports.my2ndExport = results.my2ndExport;
    
  })((function () {
  var exports = function () {
    return 'js module';
  };
  return {  my1stExport: my1stExport, my2ndExport: my2ndExport };
})());

})(this);