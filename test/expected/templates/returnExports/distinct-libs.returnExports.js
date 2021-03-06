// Uses Node, AMD or browser globals to create a module.

// If you want something that will work in other stricter CommonJS environments,
// or if you need to create a circular dependency, see commonJsStrict.js

// Defines a module "returnExports" that depends another module called "b".
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
        
        define(["lib-b-amd"], function (libB) { return factory(void 0,libB); });
    } else if (typeof module === 'object' && module.exports) {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like environments that support module.exports,
        // like Node.
        
        module.exports = factory(void 0, require("lib-b-node"));
    } else {
        // Browser globals (root is window)
        
        root.distinctLibs = factory(void 0, root.libBWeb);
    }
}(this, function (libA,libB) {
  var exports = function () {
    return 'js module';
  };
  return exports;
}));
