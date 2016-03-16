dot = require('dot')
path = require('path')
fs = require('fs')
extend = require('extend')
gutil = require('gulp-util')
es = require('event-stream')

defaultOptions = {
  templateCache: true
  templateName: 'amd.dot'
  modes: ['cjs', 'amd', 'global', 'default']
  indent: true
}

# Needs to work unescaped in a regex
MAGIC = '46e50563-66cc-4cd3-8dcf-46c527554f54'

templateSettings = extend({}, dot.templateSettings, { strip: false })

wrap = (file, options, cb) ->
  it = {
    options: options
    file: file
    jsonify: (data) ->
      JSON.stringify(data)
  }

  options.require ?= {}

  for mode in (options.modes ? [])
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

  render = (contents) ->
    contents = contents.toString()
    it.trueContents = contents
    it.contents = MAGIC

    # render template with alternate content
    output = it.options.template(it)

    # replace template with indented content
    output = output.replace(new RegExp('(?:^([ \t]*))?' + MAGIC, 'gm'), (match, indent) ->
      if it.options.indent
        return indent + contents.replace(/\r\n|\n/g, '\n' + indent)
      else
        return contents
    )

    # return a buffer
    return new Buffer(output)

  if gutil.isStream(file.contents)
    es.wait((err, contents) ->
      file.contents = render(contents)
      cb(null, file)
      return
    )
    return
  else
    file.contents = render(file.contents)
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


