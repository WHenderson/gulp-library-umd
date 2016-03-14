dot = require('dot')
path = require('path')
fs = require('fs')
extend = require('extend')
gutil = require('gulp-util')
es = require('event-stream')

defaultOptions = {
  templateCache: true
  templateName: 'amd.dot'
}

templateSettings = extend({}, dot.templateSettings, { strip: false })

wrap = (file, options, cb) ->
  it = {
    options: options
    file: file
    jsonify: (data) ->
      JSON.stringify(data)
  }

  options.require ?= {}

  for mode in ['cjs', 'amd', 'global', 'default']
    options[mode] = {
      require: {}
      args: []
      libs: []
      exports: options.exports
      namespace: options.namespace
    }

    for own arg, lib of options.require
      options[mode].require[arg] = if typeof lib == 'string' then lib else lib[mode] ? lib.name

    options[mode].args = Object.keys(options[mode].require)
    options[mode].libs = Object.keys(options[mode].require).map((k) -> options[mode].require[k])

  render = () ->
    new Buffer(it.options.template(it))

  if gutil.isStream(file.contents)
    es.wait((err, contents) ->
      it.contents = contents
      debugger
      file.contents = render()
      cb(null, file)
      return
    )
    return
  else
    it.contents = file.contents
    debugger
    file.contents = render()
    cb(null, file)
    return

module.exports = (overrides) ->
  overrides = extend(true, {}, defaultOptions, overrides)

  cache = {}

  return es.map((file, cb) ->
    options = extend(true, {}, file.data, overrides)

    name = path.basename(file.path, path.extname(file.path)).replace(/(?:\W|_)+(\w)/g, (match, ch) -> ch.toUpperCase()).replace(/\W/g, '')
    options.exports ?= name
    options.namespace ?= name

    if options.templateName? and not options.templatePath?
      options.templatePath = path.join(__dirname, '../templates', options.templateName)

    if options.templatePath?
      if options.templateCache and cache[options.templatePath]?
        options.template = cache[options.templatePath]
      else
        fs.readFile(options.templatePath, 'utf8', (err, data) ->
          if err?
            return cb(err)

          template = dot.template(data, templateSettings)

          if options.templateCache
            cache[template] = template

          options.template = template

          wrap(file, options, cb)
        )
    else
      if typeof options.template == 'string'
        options.template = dot.template(options.template, templateSettings)

      wrap(file, options, cb)

    return
  )


