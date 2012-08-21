# [connect-offline](http://github.com/dustmason/connect-offline)

_ = require('underscore')

module.exports = offline = (options={}) ->

  options.networks ?= []
  options.fallbacks ?= {}
  options.paths ?= []

  connectOffline = module.exports.instance = new ConnectOffline options
  connectOffline.middleware


class ConnectOffline

  constructor: (@options) ->
    @latestmtime = new Date()

  header_section: ->
    "CACHE MANIFEST\n" + "# " + @latestmtime.toUTCString()

  cache_section: ->
    "\nCACHE:\n" + @options.paths.join("\n")

  networks_section: ->
    "\nNETWORK:\n" + @options.networks.join("\n") if @options.networks.length

  fallbacks_section: ->
    if @options.fallbacks
      "\nFALLBACK:\n" + _.map(@options.fallbacks, (second, first) ->
        first + " " + second
      ).join("\n")

  response: ->
    [
      @header_section()
      @cache_section()
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
    else
      next()
