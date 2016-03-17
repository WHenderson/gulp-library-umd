# templates

The templating system in use is [DoT.js](http://olado.github.io/doT/index.html)

## `it`

|path|description|
|----|-----------|
|it.options|gulp-library-umd options|
|it.mode|Object literal mapping for each mode available|
|it.mode.{mode}.require|arg:name mapping of each library for this mode|
|it.mode.{mode}.args|list of arg names for each library used in this mode|
|it.mode.{mode}.libs|list of library names for each library used in this mode|
|it.mode.{mode}.factoryArgs|list of args to provide to the final factory function|
|it.factory.args|list of arg names for the final factory function|