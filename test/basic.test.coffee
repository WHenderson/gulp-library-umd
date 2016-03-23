gulp = require('gulp')
path = require('path')
rename = require('gulp-rename')
fs = require('fs')
es = require('event-stream')
assert = require('chai').assert
dot = require('dot')
del = require('del')

suite('basic', () ->
  umd = null

  suiteSetup((cb) ->
    umd = require('../src/umd')

    del(path.join(__dirname, 'found'))
    .then(() ->
      cb()
    )

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
          if expectedError?l
            assert.throws(
              () -> throw err
              expectedError
            )
          else
            throw err
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
        if expectedError?
          assert.throws(
            () -> throw err
            expectedError
          )
        else
          cb(err)
      return
    )

  suite('partial', () ->
    suite('defineFactory', () ->
      validate('default', {
        templateName: 'partial/defineFactory'
      })
    )
  )

  #validate('default', undefined, 'No template specified')

  if false
    validate('templateName-amdWeb', {
      templateName: 'amdWeb'
    })
    validate('templateName-amdWebGlobal', {
      templateName: 'amdWebGlobal'
    })
    validate('templateName-commonjsAdapter', {
      templateName: 'commonjsAdapter'
      require: {
        a: 'lib-a'
        b: 'lib-b'
      }
    })
    validate('templateName-commonjsStrict', {
      templateName: 'commonjsStrict'
      require: {
        a: 'lib-a'
        b: 'lib-b'
      }
    })
)