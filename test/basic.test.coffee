gulp = require('gulp')
path = require('path')
rename = require('gulp-rename')
fs = require('fs')
es = require('event-stream')
assert = require('chai').assert
dot = require('dot')
del = require('del')
extend = require('extend')
sourceMaps = require('gulp-sourcemaps')
coffee = require('gulp-coffee')

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

    suite('exportsCjs', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, '../templates/exportsCjs.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/exportsCjs.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/exportsCjs.def')
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

    suite('globals', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/globals.dot')
      })

      validate('requires.js', {
        templatePath: path.join(__dirname, 'fixtures/templates/globals.dot')
        require: {
          libA: 'lib-a'
          libB: { name: 'lib-b' }
          libC: { name: 'lib-c', amd: 'lib-c-amd'}
          libD: { name: 'lib-d', amd: null }
        }
      })
    )
  )

  suite('templates', () ->
    templates = [
      'amdWeb'
    ]
    optionSets = [
      {
        description: 'default'
      }
      {
        description: 'libs'
        require: {
          libA: 'lib-a'
          libB: 'lib-b'
          libC: 'lib-c'
        }
      }
      {
        description: 'distinct-libs'
        require: {
          libA: { name: 'lib-a', cjs: null, node: null, amd: null, web: null }
          libB: { name: 'lib-b', cjs: 'lib-b-cjs', node: 'lib-b-node', amd: 'lib-b-amd', web: 'libBWeb' }
        }
      }
      {
        description: 'exports-string'
        exports: 'myExports'
      }
      {
        description: 'exports-array'
        exports: ['my1stExport', 'my2ndExport']
      }
    ]

    for template in ['amd', 'amdWeb', 'amdCommonWeb', 'amdWebGlobal', 'common', 'commonjsAdapter', 'commonjsStrict', 'commonjsStrictGlobal', 'jqueryPlugin', 'node', 'nodeAdapter', 'returnExports', 'returnExportsGlobal', 'umd', 'umdGlobal', 'web']
      do (template) ->
        suite(template, () ->
          for optionsSet in optionSets
            do (optionsSet) ->
              options = extend({}, optionsSet, { templateName: template })
              if template == 'jqueryPlugin'
                options.require = extend({ '$': 'jquery' }, options.require)

              validate(optionsSet.description + '.js', options)
        )
  )

  suite('sourceMaps', () ->
    test('coffee', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.coffee'))
      .pipe(sourceMaps.init())
      .pipe(coffee())
      .pipe(rename((p) =>
        p.basename = 'coffee'
        return
      ))
      .pipe(umd({
        templateName: 'amd'
      }))
      .pipe(sourceMaps.write())
      .pipe(gulp.dest(path.join(__dirname, 'found/sourceMaps')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/sourceMaps', file.basename), 'utf8', (err, data) ->
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

    test('simple', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'))
      .pipe(sourceMaps.init())
      .pipe(rename((p) =>
        p.basename = 'simple'
        return
      ))
      .pipe(umd({
        templateName: 'amd'
      }))
      .pipe(sourceMaps.write())
      .pipe(gulp.dest(path.join(__dirname, 'found/sourceMaps')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/sourceMaps', file.basename), 'utf8', (err, data) ->
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
  )
)