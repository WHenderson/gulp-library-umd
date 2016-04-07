# gulp-library-umd
Gulp plugin for transforming node modules into various flavors of UMD (Universal Module Definition).
Wraps files with a specified UMD template.

*Supports [gulp-sourcemaps](https://www.npmjs.com/package/gulp-sourcemaps)!*
*Supports [gulp-data](https://www.npmjs.com/package/gulp-data)!*

## Templates
`gulp-library-umd` supports many templates out of the box, including all those provided by [UMDjs](https://github.com/umdjs/umd) and [gulp-umd](https://github.com/eduardolundgren/gulp-umd)

 
| origin                                                  | template                | amd | web | cjs | node | notes |
| :-----                                                  | :---------------------- | :-: | :-: | :-: | :--: | :---- |
| [UMDjs](https://github.com/umdjs/umd)                   | amdWeb.js               |  X  |  X  |     |      | Uses AMD or browser globals to create a module |
| [UMDjs](https://github.com/umdjs/umd)                   | amdWebGlobal.js         |  X  |  X  |     |      | Uses AMD or browser globals to create a module. Creates a web global when AMD is used | 
| [UMDjs](https://github.com/umdjs/umd)                   | commonjsAdapter.js      |  X  |     |  X  |      | Defines a module that works in CommonJS and AMD |
| [UMDjs](https://github.com/umdjs/umd)                   | commonjsStrict.js       |  X  |  X  |  X  |      | Uses CommonJS, AMD or browser globals to create a module |
| [UMDjs](https://github.com/umdjs/umd)                   | commonjsStrictGlobal.js |  X  |  X  |  X  |      | Uses CommonJS, AMD or browser globals to create a module. Creates a web global when AMD is used |
| [UMDjs](https://github.com/umdjs/umd)                   | jqueryPlugin.js         |  X  |  X  |  X  |  X   | Uses CommonJS, AMD or browser globals to create a jQuery plugin |
| [UMDjs](https://github.com/umdjs/umd)                   | nodeAdapter.js          |  X  |     |     |  X   | Defines a module that works in Node and AMD |
| [UMDjs](https://github.com/umdjs/umd)                   | returnExports.js        |  X  |  X  |     |  X   | Uses Node, AMD or browser globals to create a module. |
| [UMDjs](https://github.com/umdjs/umd)                   | returnExportsGlobal.js  |  X  |  X  |     |  X   | Uses Node, AMD or browser globals to create a module. Creates a web global when AMD is used |
| [gulp-umd](https://github.com/eduardolundgren/gulp-umd) | amd.js                  |  X  |     |     |      |   |
| [gulp-umd](https://github.com/eduardolundgren/gulp-umd) | amdCommonWeb.js         |  X  |  X  |  X  |      |   |
| [gulp-umd](https://github.com/eduardolundgren/gulp-umd) | common.js               |     |     |  X  |      |   |
| [gulp-umd](https://github.com/eduardolundgren/gulp-umd) | node.js                 |     |     |     |  X   |   |
| [gulp-umd](https://github.com/eduardolundgren/gulp-umd) | web.js                  |     |  X  |     |      |   |
| [gulp-library-umd](./)                                  | umd.js                  |  X  |  X  |  X  |  X   | Simple support for each of the major export platforms |
| [gulp-library-umd](./)                                  | umdGlobal.js            |  X  |  X  |  X  |  X   | Simple support for each of the major export platforms. Creates a web global when AMD is used |

## Usage

```js
var gulp = require('gulp');
var gulpSourceMaps = require('gulp-source-maps'); // optional
var gulpData = require('gulp-data'); // optional
var gulpLibraryUmd = require('gulp-library-umd')

gulp.task('build', function () {
  return gulp.src('src/**/*.js')
  .pipe(gulpData(function (file) {
     return {};
  }))
  .pipe(gulpSourceMaps.init())
  ...
  .pipe(gulpLibraryUmd({ templateName: 'umd' }))
  .pipe(gulpSourceMaps.write())
  .pipe(gulp.dest('dist'))
});
```

## Options

| name            | type       | default     | description |
| --------------- | ---------- | ----------- | ----------- |
| `templateCache` | `Boolean`  | `true`      | Cache compiled templates |
| `templateName`  | `String`   | `undefined` | Name of the template to use. Overrides `templatePath` |
| `templatePath`  | `String`   | `undefined` | Full file path of the template to use. Overrides `template` |
| `template`      | `String`   | `undefined` | [doT.js](http://olado.github.io/doT/index.html) template source to be compiled and used |
| `template`      | `Function` | `undefined` | function which takes a single argument, context, and returns a string | 
| `modes`         | `Array`    | `['cjs', 'node', 'amd', 'web']` | List of modes to support. Used when providing distinct libraries for each mode |
| `indent`        | `Boolean`  | `true`      | Indent content according to the specified template |
| `rename`        | `Boolean`  | `true`      | Rename files to include the template name as an extension suffix on the basename. eg, `source.js` -> `source.amd.js` |
| `require`       | `Object`   | `{}`        | `variable name`:`library name id` mapping of each required library |
| `exports`       | `String`   | `exports`   | Name of the variable to export. In CommonJs, only own properties of this variable will be exported. |
| `exports`       | `Array`    |             | List of names to exports. In most modes, these will be exported as an object literal with the given properties |
| `namespace`     | `String`   | undefined   | Name to use when exporting as a global. Used in `web` and global modes. If no namespace is provied, one will be generated from the filename |

### Specifying libraries

**No libraries**
```js
gulpLibraryUmd({ })
```

**Identical libraries for each mode**
```js
gulpLibraryUmd({ 
  requires: { 
    libA: 'library-a', 
    libB: 'library-b' 
  } 
}) 
```

**Different libraries for each mode**
```js
gulpLibraryUmd({ 
  requires: { 
    libA: {
      name: 'library-a', // used as default name when no alternative is specified for the mode
      web : 'libraryA',  // web globals should be valid identifiers 
      amd : null         // AMD does not require this library
    }
  } 
})
```

## Installation

```
npm install --save-dev gulp-library-data
```
