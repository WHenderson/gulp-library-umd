
(function (libA,libB){
  var exports = function () {
    return 'js module';
  };
  module.exports = exports;
})(void 0, require("lib-b-node"));