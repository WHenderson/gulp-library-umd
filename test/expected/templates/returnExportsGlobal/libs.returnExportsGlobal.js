// Uses Node, AMD or browser globals to create a module. This example creates
// a global even when AMD is used. This is useful if you have some scripts
// that are loaded by an AMD loader, but they still want access to globals.
// If you do not need to export a global for the AMD case,
// see returnExports.js.

// If you want something that will work in other stricter CommonJS environments,
// or if you need to create a circular dependency, see commonJsStrictGlobal.js

// Defines a module "returnExportsGlobal" that depends another module called
// "b". Note that the name of the module is implied by the file name. It is
// best if the file name and the exported global have matching names.

// If the 'b' module also uses this type of boilerplate, then
// in the browser, it will create a global .b that is used below.

(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        define(["lib-a","lib-b","lib-c"], function (libA,libB,libC) { return root.libs = factory(libA,libB,libC); });
    } else if (typeof module === 'object' && module.exports) {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like enviroments that support module.exports,
        // like Node.
        
        module.exports = factory(require("lib-a"), require("lib-b"), require("lib-c"));
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