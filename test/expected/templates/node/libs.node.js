
(function (libA,libB,libC){
  var exports = function () {
    return 'js module';
  };
  module.exports = exports;
})(require("lib-a"), require("lib-b"), require("lib-c"));