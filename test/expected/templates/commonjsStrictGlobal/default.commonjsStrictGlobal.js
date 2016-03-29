// Uses CommonJS, AMD or browser globals to create a module. This example
// creates a global even when AMD is used. This is useful if you have some
// scripts that are loaded by an AMD loader, but they still want access to
// globals. If you do not need to export a global for the AMD case, see
// commonjsStrict.js.

// If you just want to support Node, or other CommonJS-like environments that
// support module.exports, and you are not creating a module that has a
// circular dependency, then see returnExportsGlobal.js instead. It will allow
// you to export a function as the module value.

// Defines a module "commonJsStrictGlobal" that depends another module called
// "b". Note that the name of the module is implied by the file name. It is
// best if the file name and the exported global have matching names.

// If the 'b' module also uses this type of boilerplate, then
// in the browser, it will create a global .b that is used below.

(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        
        define(["exports"], function (exports) { factory((root.default = exports)); });
    } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
        // CommonJS
        
        factory(exports);
    } else {
        // Browser globals
        
        factory((root.default = {}));
    }
}(this, function (exports) {

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

}));
