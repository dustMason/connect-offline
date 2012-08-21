# [connect-offline](http://github.com/dustmason/connect-offline)

#fs = require('fs')
#Utils = require('../utils')
#Url = require('url')
#Path = require('path')

module.exports = offline = (options={}) ->

  options.networks ?= []
  options.fallbacks ?= []
  options.paths ?= []

  connectOffline = module.exports.instance = new ConnectOffline options
  connectOffline.middleware


class ConnectOffline

  constructor: (@options) ->
    @latestmtime = new Date()

  header_section: ->
    "CACHE MANIFEST\n" + "# " + @latestmtime.toUTCString()

  files_section: ->
    "\n\nCACHE:\n" + @options.paths.join("\n")

  networks_section: ->
    "\n\nNETWORK:\n" + @options.networks.join("\n")

  fallbacks_section: ->
    "\n\nFALLBACK:\n" + @options.fallbacks.map((second, first) ->
      first + " " + second
    ).join("\n")

  response: ->
    [
      @header_section()
      @files_section()
      @networks_section()
      @fallbacks_section()
    ].join("\n")

  middleware: (req, res, next) =>
    if "/application.manifest" == req.url
      manifest = @response()
      res.writeHead 200,
        "Content-Type": "text/cache-manifest"
        "Last-Modified": @latestmtime.toUTCString()
        "Content-Length": manifest.length
      res.end manifest
    next()
