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
    test(path.basename(name, path.extname(name)), (cb) ->

      testPath = []
      node = @test.parent
      while node?
        testPath.unshift(node.title)
        node = node.parent
      testPath = path.join.apply(null, testPath.slice(2))

      try
        gulp
        .src(path.join(__dirname, 'fixtures/fixture-content' + (path.extname(name) ? '.js')))
        .pipe(rename((p) =>
          ext = path.extname(name)
          if ext?
            p.basename = path.basename(name, ext)
            p.extname = ext
          else
            p.basename = name
          return
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
        .pipe(gulp.dest(path.join(__dirname, 'found', testPath)))
        .pipe(es.map((file, cb) ->
          fs.readFile(path.join(__dirname, 'expected', testPath, file.basename), 'utf8', (err, data) ->
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

  suite('context', () ->
    validate('default.json', {
      templateName: 'context.dot'
    })

    validate('requires.json', {
      templateName: 'context.dot'
      require: {
        libA: 'lib-a'
        libB: { name: 'lib-b' }
        libC: { name: 'lib-c', amd: 'lib-c-amd'}
        libD: { name: 'lib-d', amd: null }
      }
    })
  )

  suite('snippets', () ->
    suite('exports', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, '../templates/exports.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/exports.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/exports.def')
        exports: ['exportA', 'exportB', 'exportC']
      })
    )

    suite('defineFactory', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, '../templates/defineFactory.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/defineFactory.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/defineFactory.def')
        exports: ['exportA', 'exportB', 'exportC']
      })

      validate('requires.js', {
        templatePath: path.join(__dirname, '../templates/defineFactory.def')
        require: {
          libA: 'lib-a'
          libB: { name: 'lib-b' }
          libC: { name: 'lib-c', amd: 'lib-c-amd'}
          libD: { name: 'lib-d', amd: null }
        }
      })
    )

    suite('defineFactoryMapped', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/defineFactoryMapped.dot')
      })

      validate('requires.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/defineFactoryMapped.dot')
        require: {
          libA: 'lib-a'
          libB: { name: 'lib-b' }
          libC: { name: 'lib-c', amd: 'lib-c-amd'}
          libD: { name: 'lib-d', amd: null }
        }
      })
    )

    suite('requires', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/requires.dot')
      })

      validate('requires.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/requires.dot')
        require: {
          libA: 'lib-a'
          libB: { name: 'lib-b' }
          libC: { name: 'lib-c', amd: 'lib-c-amd'}
          libD: { name: 'lib-d', amd: null }
        }
      })
    )
  )
)