// Uses CommonJS, AMD or browser globals to create a jQuery plugin.

(function (factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        
        define(["jquery","lib-a","lib-b","lib-c"], factory);
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
            factory(jQuery, require("lib-a"), require("lib-b"), require("lib-c"));
            return jQuery;
        };
    } else {
        // Browser globals
        
        factory(jquery, lib-a, lib-b, lib-c);
    }
}(function ($,libA,libB,libC) {
  var exports = function () {
    return 'js module';
  };
}));
