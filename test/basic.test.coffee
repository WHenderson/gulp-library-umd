gulp = require('gulp')
path = require('path')
rename = require('gulp-rename')
fs = require('fs')
es = require('event-stream')
assert = require('chai').assert
dot = require('dot')

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
  validate('with-libs', {
    require: {
      argA: 'lib-a'
      argB: 'lib-b'
      argC: { name: 'lib-c', amd: 'lib-c2' }
    }
  })
  validate('no-indent', {
    indent: false
  })
  validate('no-rename', {
    rename: false
  })
  validate('by-path', {
    templatePath: path.join(__dirname, '../templates/amd.dot')
  })
  validate('by-template-string', {
    template: fs.readFileSync(path.join(__dirname, '../templates/amd.dot'), 'utf8')
  })
  validate('by-template-func', {
    template: dot.template(fs.readFileSync(path.join(__dirname, '../templates/amd.dot'), 'utf8'))
  })
  validate('exports', {
    exports: 'exports'
  })

  for name in ['amd', 'node']
    validate("#{name}-by-name", {
      templateName: name
      exports: 'exports'
    })
    validate("#{name}-by-path", {
      templatePath: path.join(__dirname, "../templates/#{name}.dot")
      exports: 'exports'
    })
    validate("#{name}-with-libs", {
      templateName: name
      require: {
        argA: 'lib-a'
        argB: {
          name: 'lib-b',
          amd: null
          cjs: null
          global: null
          default: null
        }
        argC: {
          name: 'lib-c',
          amd: 'lib-c-amd'
          cjs: 'lib-c-cjs'
          global: 'lib-c-global'
          default: 'lib-c-default'
        }
        argD: {
          name: null,
          amd: 'lib-d-amd'
          cjs: 'lib-d-cjs'
          global: 'lib-d-global'
          default: 'lib-d-default'
        }
      }
      exports: 'exports'
    })

)