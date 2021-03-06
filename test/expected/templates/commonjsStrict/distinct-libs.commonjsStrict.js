// Uses CommonJS, AMD or browser globals to create a module.

// If you just want to support Node, or other CommonJS-like environments that
// support module.exports, and you are not creating a module that has a
// circular dependency, then see returnExports.js instead. It will allow
// you to export a function as the module value.

// Defines a module "commonJsStrict" that depends another module called "b".
// Note that the name of the module is implied by the file name. It is best
// if the file name and the exported global have matching names.

// If the 'b' module also uses this type of boilerplate, then
// in the browser, it will create a global .b that is used below.

// If you do not want to support the browser global path, then you
// can remove the `root` use and the passing `this` as the first arg to
// the top function.

(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        define(["exports","lib-b-amd"], function (exports, libB) { factory(exports, void 0,libB); });
    } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
        // CommonJS
        
        factory(exports,void 0, require("lib-b-cjs"));
    } else {
        // Browser globals
        
        factory((root.distinctLibs = {}),void 0, root.libBWeb);
    }
}(this, function (exports,libA,libB) {

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

}));
