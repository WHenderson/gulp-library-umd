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
gdata = require('gulp-data')

suite('basic', () ->
  umd = null
  @timeout(10000)

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
          if expectedError?
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
        templatePath: path.join(__dirname, '../templates/def/exports.js.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/def/exports.js.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/def/exports.js.def')
        exports: ['exportA', 'exportB', 'exportC']
      })
    )

    suite('exportsCjs', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, '../templates/def/exportsCjs.js.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/def/exportsCjs.js.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/def/exportsCjs.js.def')
        exports: ['exportA', 'exportB', 'exportC']
      })
    )

    suite('defineFactory', () ->
      validate('default.js', {
        templatePath: path.join(__dirname, '../templates/def/defineFactory.js.def')
      })

      validate('string.js', {
        templatePath: path.join(__dirname, '../templates/def/defineFactory.js.def')
        exports: 'myExports'
      })

      validate('array.js', {
        templatePath: path.join(__dirname, '../templates/def/defineFactory.js.def')
        exports: ['exportA', 'exportB', 'exportC']
      })

      validate('requires.js', {
        templatePath: path.join(__dirname, '../templates/def/defineFactory.js.def')
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

  suite('options', () ->
    test('no indent', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'))
      .pipe(rename((p) =>
        p.basename = 'no-indent'
        return
      ))
      .pipe(umd({
        templateName: 'amd'
        indent: false
      }))
      .pipe(sourceMaps.write())
      .pipe(gulp.dest(path.join(__dirname, 'found/options')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/options', file.basename), 'utf8', (err, data) ->
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

    test('unexpected-mode', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'))
      .pipe(rename((p) =>
        p.basename = 'unexpected-mode'
        return
      ))
      .pipe(umd({
        templateName: 'amd'
        modes: []
        require: {
          libA: 'lib-a'
          libB: {
            name: 'lib-b-default'
            amd: 'lib-b-amd'
          }
        }
        indent: false
      }))
      .pipe(sourceMaps.write())
      .pipe(gulp.dest(path.join(__dirname, 'found/options')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/options', file.basename), 'utf8', (err, data) ->
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

    test('template-string', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'))
      .pipe(rename((p) =>
        p.basename = 'template-string'
        return
      ))
      .pipe(umd({
        template: '''
          // from template string
          // start js
          {{= it.contents }}
          // end js
        '''
      }))
      .pipe(sourceMaps.write())
      .pipe(gulp.dest(path.join(__dirname, 'found/options')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/options', file.basename), 'utf8', (err, data) ->
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

  suite('integration', () ->
    test('gulp-data', (cb) ->
      gulp
      .src([
        path.join(__dirname, 'fixtures/fixture-content.js'),
        path.join(__dirname, 'fixtures/fixture-content.json')
      ])
      .pipe(rename((p) =>
        p.basename = 'gulp-data'
        return
      ))
      .pipe(gdata((file) ->
        switch path.extname(file.basename)
          when '.json' then { templatePath: path.join(__dirname, 'fixtures/templates/simple-wrap-json.dot') }
          when '.js' then { templatePath: path.join(__dirname, 'fixtures/templates/simple-wrap-js.dot') }
      ))
      .pipe(umd())
      .pipe(gulp.dest(path.join(__dirname, 'found/integration')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/integration', file.basename), 'utf8', (err, data) ->
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

  suite('other', () ->
    test('cache', (cb) ->
      gulp
      .src([
        path.join(__dirname, 'fixtures/fixture-content.js'),
        path.join(__dirname, 'fixtures/fixture-content.json')
      ])
      .pipe(rename((p) =>
        p.basename = 'cache-' + p.extname.slice(1)
        return
      ))
      .pipe(umd({
        templatePath: path.join(__dirname, 'fixtures/templates/simple-wrap-js.dot')
        templateCache: false
      }))
      .pipe(gulp.dest(path.join(__dirname, 'found/other')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/other', file.basename), 'utf8', (err, data) ->
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

    test('no-cache', (cb) ->
      gulp
      .src([
        path.join(__dirname, 'fixtures/fixture-content.js'),
        path.join(__dirname, 'fixtures/fixture-content.json')
      ])
      .pipe(rename((p) =>
        p.basename = 'no-cache-' + p.extname.slice(1)
        return
      ))
      .pipe(umd({ templatePath: path.join(__dirname, 'fixtures/templates/simple-wrap-js.dot') }))
      .pipe(gulp.dest(path.join(__dirname, 'found/other')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/other', file.basename), 'utf8', (err, data) ->
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

    test('unknown template', () ->
      new Promise((resolve, reject) ->
        gulp
        .src(path.join(__dirname, 'fixtures/fixture-content.js'))
        .pipe(umd({ templateName: 'unknown' }))
        .on('error', (err) ->
          reject(err)
          @emit('end')
          @end()
        )
        .on('end', () -> resolve())
      )
      .then(
        () -> throw new Error('Did not throw')
        (err) ->
          assert.throws(
            () -> throw err
            'ENOENT: no such file or directory'
          )
      )
    )

    test('no template', () ->
      new Promise((resolve, reject) ->
        gulp
        .src(path.join(__dirname, 'fixtures/fixture-content.js'))
        .pipe(umd({ }))
        .on('error', (err) ->
          reject(err)
          @emit('end')
          @end()
        )
        .on('end', () -> resolve())
      )
      .then(
        () -> throw new Error('Did not throw')
        (err) ->
          assert.throws(
            () -> throw err
            'No template specified'
          )
      )
    )

    test('stream', (cb) ->
      gulp
      .src(path.join(__dirname, 'fixtures/fixture-content.js'), { buffer: false })
      .pipe(rename((p) =>
        p.basename = 'stream'
        return
      ))
      .pipe(umd({ templateName: 'amd' }))
      .pipe(gulp.dest(path.join(__dirname, 'found/other')))
      .pipe(es.map((file, cb) ->
        fs.readFile(path.join(__dirname, 'expected/other', file.basename), 'utf8', (err, data) ->
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