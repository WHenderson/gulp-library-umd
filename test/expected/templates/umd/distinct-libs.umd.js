(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    
    define(["lib-b-amd"], function (libB) { return factory(void 0,libB); });
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    
    module.exports = factory(void 0, require("lib-b-node"));
  } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
    // CommonJs
    
    (function (results) {
      
      for (var key in results) {
        if ({}.hasOwnProperty.call(results, key))
          exports[key] = results[key];
      }
      
    })(factory(void 0, require("lib-b-cjs")));
  } else {
   // Browser globals
   
   root.distinctLibs = factory(void 0, root.libBWeb);
  }
}(this, function (libA,libB) {
  var exports = function () {
    return 'js module';
  };
  return exports;
}));
