gulp = require('gulp')
path = require('path')
rename = require('gulp-rename')
fs = require('fs')
es = require('event-stream')
assert = require('chai').assert
dot = require('dot')
rimraf = require('gulp-rimraf')

suite('basic', () ->
  umd = null

  setup((cb) ->
    umd = require('../src/umd')

    gulp.src(path.join(__dirname, 'found'), { read: false, allowEmpty: true })
    .pipe(rimraf())
    .on('finish', cb)

    return
  )

  validate = (name, options, expectedError) ->
    test(name, (cb) ->
      try
        gulp
        .src(path.join(__dirname, 'fixtures/fixture-content.js'))
        .pipe(rename((path) =>
          path.basename = name
        ))
        .pipe(umd(options))
        .on('error', (err) ->
          assert.throws(
            () -> throw err
            expectedError
          )
          @emit('end')
          @end()
        )
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
      catch err
        console.log('hmm')
        assert.throws(
          () -> throw err
          expectedError
        )
      return
    )

  validate('default', undefined, 'No template specified')
)