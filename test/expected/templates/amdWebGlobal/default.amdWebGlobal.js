// Uses AMD or browser globals to create a module. This example creates a
// global even when AMD is used. This is useful if you have some scripts
// that are loaded by an AMD loader, but they still want access to globals.
// If you do not need to export a global for the AMD case, see amdWeb.js.

// If you want something that will also work in Node, and still export a
// global in the AMD case, see returnExportsGlobal.js
// If you want to support other stricter CommonJS environments,
// or if you need to create a circular dependency, see commonJsStrictGlobal.js

// Defines a module "amdWebGlobal" that depends another module called "b".
// Note that the name of the module is implied by the file name. It is best
// if the file name and the exported global have matching names.

// If the 'b' module also uses this type of boilerplate, then
// in the browser, it will create a global .b that is used below.

(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        define([], function () { return root.default = factory(); });
    } else {
        // Browser globals
        
        root.default = factory();
    }
}(this, function () {
  var exports = function () {
    return 'js module';
  };
  return exports;
}));