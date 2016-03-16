(function (argA, argC, argD){
  var exports = function () {
    return 'js module';
  };
  module.exports = exports;
})(require("lib-a"), require("lib-c-cjs"), require("lib-d-cjs"));