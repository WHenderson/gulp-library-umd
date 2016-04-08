var gulp = require('gulp');
var gulpSourceMaps = require('gulp-sourcemaps'); // optional
var gulpData = require('gulp-data'); // optional
var gulpLibraryUmd = require('../../')

gulp.task('build', function () {
  return gulp.src('source.js')
    // optional per-file settings
    .pipe(gulpData(function (file) {
      return {};
    }))
    // optional source map support
    .pipe(gulpSourceMaps.init())
    // ...
    .pipe(gulpLibraryUmd({
      templateName: 'umd',
      require: {
        libA: 'libA',
        libB: {
          name: 'lib-b-default',
          amd: 'lib-b-amd',
          cjs: 'lib-b-cjs',
          node: 'lib-b-node',
          web: 'libBWeb'
        }
      },
      exports: 'result',
      namespace: 'myModuleGlobal'
    }))
    .pipe(gulpSourceMaps.write())
    .pipe(gulp.dest('dist'))
});
