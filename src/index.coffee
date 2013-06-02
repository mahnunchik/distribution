Distribution = require './Distribution'
css = require './processors/css'

module.exports = (options={})->
  options.processors ?=
    processors:
      'text/css': css
  return new Distribution options
    

module.exports.Distribution = Distribution
module.exports.cssProcessor = css