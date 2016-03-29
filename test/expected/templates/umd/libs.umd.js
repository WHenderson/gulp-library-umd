(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module.
    
    define(["lib-a","lib-b","lib-c"], factory);
  } else if (typeof module === 'object' && module.exports) {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    
    module.exports = factory(require("lib-a"), require("lib-b"), require("lib-c"));
  } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
    // CommonJs
    
    (function (results) {
      
      for (var key in results) {
        if ({}.hasOwnProperty.call(results, key))
          exports[key] = results[key];
      }
      
    })(factory(require("lib-a"), require("lib-b"), require("lib-c")));
  } else {
   // Browser globals
   
   root.libs = factory(root.lib-a, root.lib-b, root.lib-c);
  }
}(this, function (libA,libB,libC) {
  var exports = function () {
    return 'js module';
  };
  return exports;
}));
