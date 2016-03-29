// Defines a module that works in CommonJS and AMD.

// This version can be used as common boilerplate for a library module
// that you only want to expose to CommonJS and AMD loaders. It will not work
// well for defining browser globals.

// If you only want to target Node and AMD or a CommonJS environment that
// supports assignment to module.exports and you are not defining a module
// that has a circular dependency, see nodeAdapter.js

// Help Node out by setting up define.
if (typeof exports === 'object' && typeof exports.nodeName !== 'string' && typeof define !== 'function') {
    var define = function (factory) {
        factory(require, exports, module);
    };
}

define(function (require, exports, module) {
    
    
    
    

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
});
