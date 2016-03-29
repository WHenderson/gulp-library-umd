// Uses CommonJS, AMD or browser globals to create a jQuery plugin.

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        define(["jquery","lib-b-amd"], function ($,libB) { return factory($,void 0,libB); });
    } else if (typeof module === 'object' && module.exports) {
        // Node/CommonJS
        
        module.exports = function( root, jQuery ) {
            if ( jQuery === undefined ) {
                // require('jQuery') returns a factory that requires window to
                // build a jQuery instance, we normalize how we use modules
                // that require this pattern but the window provided is a noop
                // if it's defined (how jquery works)
                if ( typeof window !== 'undefined' ) {
                    jQuery = require("jquery");
                }
                else {
                    jQuery = require("jquery")(root);
                }
            }
            factory(jQuery, void 0, require("lib-b-cjs"));
            return jQuery;
        };
    } else {
        // Browser globals
        
        factory(jquery, void 0, libBWeb);
    }
}(function ($,libA,libB) {
  var exports = function () {
    return 'js module';
  };
}));
