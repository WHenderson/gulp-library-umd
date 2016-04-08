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
  for source in fs.readdirSync(path.join(__dirname, '../templates/def')).sort()
    if path.extname(source) == '.def'
      name = path.basename(source, path.extname(source))
      ext = path.extname(name)
      if ext != ''
        name = path.basename(name, ext) + ext[1].toUpperCase() + ext.slice(2)
      defines[name] = fs.readFileSync(path.join(__dirname, '../templates/def', source))
  return defines

namespace = (filePath) ->
  path.basename(filePath, path.extname(filePath))
  .replace(
    /(?:\W|_)+(\w)/g,
    (match, ch) ->
      ch.toUpperCase()
  )
  .replace(/\W/g, '')

render = (file, it, contents) ->
  MAGIC = '(void "46e50563-66cc-4cd3-8dcf-46c527554f54")'
  contents = contents.toString()

  # Use a placeholder for contents
  it.trueContents = contents
  it.contents = MAGIC

  # render template with alternate content
  output = it.options.template(it).replace(/\r\n|\n/g, '\n')

  if file.sourceMap?
    sourceMap = require('source-map')
    applySourceMap = require('vinyl-sourcemaps-apply')
    generator = new sourceMap.SourceMapGenerator(file.sourceMap)
    consumer = new sourceMap.SourceMapConsumer(file.sourceMap)
    contentLineCount = contents.split('\n').length - 1

    if file.sourceMap.mappings.length == 0
      iline = 0
      while iline != contentLineCount + 1
        generator.addMapping({
          generated: {
            line: iline + 1
            column: 0
          }
          original: {
            line: iline + 1
            column: 0
          }
          source: file.sourceMap.sources[0]
          name: null
        })
        ++iline

      applySourceMap(file, generator.toString())
      generator = new sourceMap.SourceMapGenerator(file.sourceMap)
      consumer = new sourceMap.SourceMapConsumer(file.sourceMap)

  offsetLine = 0
  output = output.split(/\r\n|\n/).map((line, iline) ->
    # replace one line at a time
    line.replace(new RegExp('^([ \t]*)' + MAGIC.replace(/\(/g, '\\(').replace(/\)/g, '\\)\s*$'), 'gm'), (match, indent) ->
      indent ?= ''

      if it.options.indent and indent.length != 0
        rendered = indent + contents.replace(/\r\n|\n/g, '\n' + indent)
      else
        indent = ''
        rendered = contents

      icolumn = indent.length

      if file.sourceMap?
        consumer.eachMapping((mapping) ->
          generator.addMapping({
            generated: {
              line: mapping.generatedLine + iline + offsetLine
              column: mapping.generatedColumn + indent.length
            }
            original: {
              line: mapping.originalLine
              column: mapping.originalColumn
            }
            source: mapping.source
            name: mapping.name
          })
        )

        offsetLine += contentLineCount

      return rendered
    )
  ).join('\n')

  file.contents = new Buffer(output)

  if file.sourceMap?
    applySourceMap(file, generator.toString())

  return

rename = (file, options) ->
  if options.rename and (options.templateName? or options.templatePath?)
    ext = path.extname(options.templatePath)
    name = path.basename(options.templatePath, ext)

    if name.charAt(0) == '.'
      name = name.slice(1)

    if ext == '.dot' or ext == '.def'
      ext = path.extname(name)
      name = path.basename(name, ext)

    if not ext? or ext == ''
      ext = path.extname(file.basename)

    file.basename = path.basename(file.basename, path.extname(file.basename)) + '.' + name.replace(/\\\//g, '-') + ext

  return

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
      libStrings: []
      factoryArgs: []
    }

    for own arg, lib of options.require
      lib = if typeof lib == 'string' then lib else (if lib[mode] != undefined then lib[mode] else lib.name)
      if lib?
        it.mode[mode].require[arg] = lib
        it.mode[mode].requireArray.push({
          arg: arg
          lib: lib
          libString: JSON.stringify(lib)
        })
        it.mode[mode].args.push(arg)
        it.mode[mode].libs.push(lib)
        it.mode[mode].libStrings.push(JSON.stringify(lib))
      it.mode[mode].factoryArgs.push(if lib? then arg else 'void 0')

  if gutil.isStream(file.contents)
    file.contents.pipe(es.wait((err, contents) ->
      ### !pragma coverage-skip-next ###
      if err?
        return cb(err)

      render(file, it, contents)
      rename(file, options)
      cb(null, file)
      return
    ))
    return
  else
    render(file, it, file.contents)
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
    if options.templateName?
      if path.extname(options.templateName) == ''
        options.templateName += path.extname(file.path)
      if path.extname(options.templateName) != '.dot'
        options.templateName += '.dot'
      options.templatePath = path.join(templatesBase, options.templateName)

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
            cache[options.templatePath] = template

          options.template = template

          wrap(file, options, cb)
        )
        return

    if options.template?
      # template
      if typeof options.template == 'string'
        options.template = compile(options.template)

      wrap(file, options, cb)
      return

    throw new Error('No template specified')
  )

module.exports = pipe