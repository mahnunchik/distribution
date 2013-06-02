fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
mime = require 'mime'
mkdirp = require 'mkdirp'
glob = require 'glob'
_ = require 'underscore'

cssProcessor = require './processors/css'
console.log cssProcessor


class Distribution
  constructor: (options={})->
    @logger = options.logger || console
    @assetDir = options.assetDir || 'assets'
    @rootUrl = options.rootUrl || '/'

    @processors = options.processors || {}
    @assets = options.assets || {}

  get: (key)->
    return @assets[key]

  make: (key, filename, options)->
    if _.isObject(key)
      for own _key, opts of key
        @make(_key, opts.file, opts)
      return

    unless filename?
      filename = key

    files = glob.sync(filename, {mark: true})
    if files.length == 1 and files[0].substr(-1) != '/'
      options = options || {}
      options.assetDir ?= @assetDir
      options.rootUrl ?= @rootUrl
      return @process(key, files[0], options)
    else if files.length > 1
      for file in files
        @make(file, file, options)
    else
      @logger.error("Bad pattern: '#{filename}'") if @logger.error
      return false

  process: (key, filename, options={})->
    extname  = path.extname(filename)
    basename = path.basename(filename, extname)
    mimetype = options.mimetype || mime.lookup(extname)

    unless fs.existsSync(filename)
      @logger.error("File '#{filename}' not exists") if @logger.error
      return

    content = fs.readFileSync(filename)

    if @processors[mimetype]?
      content = @processors[mimetype](@, filename, content, options)

    name = basename
    if options.hash != false
      md5 = crypto.createHash('md5').update(content).digest('hex')
      name = "#{name}-#{md5}"
    name = "#{name}#{extname}"

    #TODO upload to CDN
    @assetLocal(options.assetDir, name, content)

    url = path.join(options.rootUrl, name)
    @assets[key] = url

    @logger.info("Created asset '#{dest}' for key '#{key}'") if @logger.info
    return true

  assetLocal: (assetDir, filename, content)->
    mkdirp.sync(assetDir)
    dest = path.join(assetDir, filename)
    fs.writeFileSync(dest, content)

  addProcessor: (mimetype, processor)->
    @processors[mimetype] = processor



module.exports = new Distribution
  processors:
    'text/css': cssProcessor

module.exports.Distribution = Distribution
module.exports.cssProcessor = cssProcessor