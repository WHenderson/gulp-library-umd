dot = require('dot')
path = require('path')
fs = require('fs')
extend = require('extend')
gutil = require('gulp-util')
es = require('event-stream')

defaultOptions = {
  ## cache rendered templates?
  templateCache: true

  ## default template to use
  templateName: undefined
  templatePath: undefined
  template: undefined

  ## list of distinct modes to support
  modes: ['cjs', 'node', 'amd', 'web']

  ## indent content according to the template
  indent: true

  ## suffix the outgoing file basename with the template name
  rename: true

  ## argName/libName mapping of all requires
  ## argName/{ name:libName, mode: libName, ..} mapping of all requires
  ## specify a null lib name to not require the module in a particular environment
  require: {}

  ## string: name of item to export
  ## array : names of items to export
  exports: 'exports'

  ## namespace of item when used in global namespace
  namespace: undefined
}

templatesBase = path.join(__dirname, '../templates')

compile = (templateSource) ->
  dot.template(templateSource, compile.settings, compile.defines)

compile.settings = extend({}, dot.templateSettings, { strip: false })

compile.defines = do ->
  defines = {}
  for source in fs.readdirSync(path.join(__dirname, '../templates')).sort()
    if path.extname(source) == '.def'
      defines[path.basename(source, path.extname(source))] = fs.readFileSync(path.join(__dirname, '../templates', source))
  return defines

namespace = (filePath) ->
  path.basename(filePath, path.extname(filePath))
  .replace(
    /(?:\W|_)+(\w)/g,
    (match, ch) ->
      ch.toUpperCase()
  )
  .replace(/\W/g, '')

render = (it, contents) ->
  MAGIC = '46e50563-66cc-4cd3-8dcf-46c527554f54'
  contents = contents.toString()


  # Use a placeholder for contents
  it.trueContents = contents
  it.contents = MAGIC

  # render template with alternate content
  output = it.options.template(it).replace(/\r\n|\n/g, '\n')

  # replace template with indented content
  output = output.replace(new RegExp('(?:^([ \t]*))?' + MAGIC, 'gm'), (match, indent = '') ->
    if it.options.indent
      return indent + contents.replace(/\r\n|\n/g, '\n' + indent)
    else
      return contents
  )

  # return a buffer
  return new Buffer(output)

rename = (file, options) ->
  if options.rename and (options.templateName? or options.templatePath?)
    if options.templateName?
      ext = options.templateName.replace(/\\\//g, '-')
    else
      ext = path.basename(options.templatePath, path.extename(options.templatePath))

    if ext
      file.basename = path.basename(file.basename, path.extname(file.basename)) + '.' + ext #+ path.extname(file.basename)
  return

jsonify = (data) ->
  JSON.stringify(data)

wrap = (file, options, cb) ->
  it = {
    options: options
    mode: {}
    factory: {
      args: Object.keys(options.require)
    }
  }

  # find comprehensive list of modes

  modes = (options.modes ? []).slice()

  for own arg, lib of options.require
    if typeof lib != 'string'
      for mode in Object.keys(lib)
        if mode != 'name' and modes.indexOf(mode) == -1
          modes.push(mode)

  # extract data for each mode

  for mode in modes
    it.mode[mode] = {
      require: {}
      requireArray: []
      args: []
      libs: []
      factoryArgs: []
    }

    for own arg, lib of options.require
      lib = if typeof lib == 'string' then lib else (if lib[mode] != undefined then lib[mode] else lib.name)
      if lib?
        it.mode[mode].require[arg] = lib
        it.mode[mode].requireArray.push({
          arg: arg
          lib: lib
        })
        it.mode[mode].args.push(arg)
        it.mode[mode].libs.push(lib)
      it.mode[mode].factoryArgs.push(if lib? then arg else 'void 0')

  if it.mode.web?
    it.mode.web.libs = it.mode.web.libs.map((lib) -> "root.#{lib}")

  if gutil.isStream(file.contents)
    es.wait((err, contents) ->
      if err?
        return cb(err)

      file.contents = render(it, contents)
      rename(file, options)
      cb(null, file)
      return
    )
    return
  else
    file.contents = render(it, file.contents)
    rename(file, options)
    cb(null, file)
    return

pipe = (overrides) ->
  overrides = extend(true, {}, defaultOptions, overrides)
  cache = {}

  return es.map((file, cb) ->
    # allow gulp-data to override
    options = extend(true, {}, file.data, overrides)

    # default namespace
    options.namespace ?= namespace(file.path)

    # templateName > templatePath > template

    # templateName
    if options.templateName? and not options.templatePath?
      if path.extname(options.templateName) == ''
        options.templateName += path.extname(file.path)
      options.templatePath = path.join(templatesBase, options.templateName + '.dot')

    # templatePath
    if options.templatePath?
      if options.templateCache and cache[options.templatePath]?
        options.template = cache[options.templatePath]
      else
        fs.readFile(options.templatePath, (err, data) ->
          if err?
            return cb(err)

          template = compile(data)

          if options.templateCache
            cache[template] = template

          options.template = template

          wrap(file, options, cb)
        )
    else
      # template
      if typeof options.template == 'string'
        options.template = compile(options.template)

      if not options.template?
        throw new Error('No template specified')

      wrap(file, options, cb)
  )

module.exports = pipe