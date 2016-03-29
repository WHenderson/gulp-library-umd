(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    
    define([], function () { return root.exportsArray = factory(); });
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    
    module.exports = factory();
  } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
    // CommonJs
    
    (function (results) {
      
      
      exports.my1stExport = results.my1stExport;
      exports.my2ndExport = results.my2ndExport;
      
    })(factory());
  } else {
   // Browser globals
   
   root.exportsArray = factory();
  }
}(this, function () {
  var exports = function () {
    return 'js module';
  };
  return {  my1stExport: my1stExport, my2ndExport: my2ndExport };
}));
