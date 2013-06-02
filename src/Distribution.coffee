fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
mime = require 'mime'
mkdirp = require 'mkdirp'
glob = require 'glob'
_ = require 'underscore'

class Distribution
  constructor: (options={})->
    @logger = options.logger || console
    @assetDir = options.assetDir || 'assets'
    @rootUrl = options.rootUrl || '/'

    @processors = options.processors || {}
    @assets = options.assets || {}

  get: (key)->
    return @assets[key]

  make: (key, filename, options={})->
    unless key?
      return
    if _.isObject(key)
      for own _key, opts of key
        if _.isObject(opts)
          @make(_key, opts.file, opts)
        else
          @make(_key, opts)
      return

    if options.url?
      @assets[key] = options.url
      return true

    unless filename?
      filename = key
    files = glob.sync(filename, {mark: true})
    options.assetDir ?= @assetDir
    options.rootUrl ?= @rootUrl
    if files.length == 1 and files[0].substr(-1) != '/'
      @process(key, files[0], options)
    else if files.length > 0
      for file in files
        if file.substr(-1) != '/'
          @process(file, file, options)
    else
      @logger.error("Bad pattern: '#{filename}'") if @logger.error

  process: (key, filename, options={})->
    extname  = path.extname(filename)
    basename = path.basename(filename, extname)
    mimetype = options.mimetype || mime.lookup(extname)

    unless fs.existsSync(filename)
      @logger.error("File '#{filename}' not exists") if @logger.error
      return false

    try
      content = fs.readFileSync(filename)
    catch err
      @logger.error err if @logger.error
      return false

    if @processors[mimetype]?
      content = @processors[mimetype](@, filename, content, options)

    name = basename
    if options.hash != false
      md5 = crypto.createHash('md5').update(content).digest('hex')
      name = "#{name}-#{md5}"
    name = "#{name}#{extname}"

    #TODO upload to CDN
    if @assetLocal(options.assetDir, name, content) == false
      return false

    url = path.join(options.rootUrl, name)
    @assets[key] = url

    @logger.info("Created asset '#{url}' for key '#{key}'") if @logger.info
    return true

  assetLocal: (assetDir, filename, content)->
    dest = path.join(assetDir, filename)
    try
      mkdirp.sync(assetDir)
      fs.writeFileSync(dest, content)
    catch err
      @logger.error err if @logger.error
      return false

  addProcessor: (mimetype, processor)->
    @processors[mimetype] = processor


module.exports = Distribution