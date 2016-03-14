gulp = require('gulp')
path = require('path')

suite('basic', () ->
  umd = null

  setup(() ->
    umd = require('../src/umd')
  )

  test('templateName', (cb) ->
    gulp
    .src(path.join(__dirname, 'fixtures/fixture-content.js'))
    .pipe(umd({
      require: {
        argA: 'lib-a'
        argB: 'lib-b'
        argC: { name: 'lib-c', amd: 'lib-c2' }
      }
    }))
    .pipe(gulp.dest(path.join(__dirname, 'output')))
    .on('end', cb)
  )
)