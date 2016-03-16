gulp = require('gulp')
path = require('path')
rename = require('gulp-rename')
fs = require('fs')
es = require('event-stream')
assert = require('chai').assert

suite('basic', () ->
  umd = null

  setup(() ->
    umd = require('../src/umd')
  )

  validate = (name, options) ->
    test(name, (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'))
      .pipe(rename((path) =>
        path.basename = name
      ))
      .pipe(umd(options))
      .pipe(gulp.dest(path.join(__dirname, 'found')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected', file.basename), 'utf8', (err, data) ->
          if err?
            return cb(err)

          assert.equal(
            file.contents.toString().replace(/\r\n|\r/g, '\n')
            data.toString().replace(/\r\n|\r/g, '\n')
            'Did not produce the expected output'
          )

          cb(null, file)
        )
      ))
      .on('end', cb)
    )

  validate('defaults')
)