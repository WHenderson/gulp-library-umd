(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    
    define([], function () { return root.exportsString = factory(); });
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    
    module.exports = factory();
  } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
    // CommonJs
    
    (function (results) {
      
      for (var key in results) {
        if ({}.hasOwnProperty.call(results, key))
          exports[key] = results[key];
      }
      
    })(factory());
  } else {
   // Browser globals
   
   root.exportsString = factory();
  }
}(this, function () {
  var exports = function () {
    return 'js module';
  };
  return myExports;
}));
