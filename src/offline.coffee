# [connect-offline](http://github.com/dustmason/connect-offline)

_ = require('underscore')
fs = require('fs')

module.exports = offline = (options={}) ->

  options.networks ?= []
  options.fallbacks ?= null
  options.files ?= []
  options.manifest_path ?= '/application.manifest'

  connectOffline = module.exports.instance = new ConnectOffline options
  connectOffline.middleware


class ConnectOffline

  constructor: (@options) ->
    @latestmtime = 0

  header_section: ->
    "CACHE MANIFEST\n" + "# " + @latestmtime.toUTCString()

  cache_section: ->
    files = []
    root = process.cwd()
    for dir in @options.files
      dir_path = root + dir.dir
      for filename in fs.readdirSync(dir_path)
        files.push(dir.prefix + filename)
        stat = fs.statSync(dir_path + '/' + filename)
        @latestmtime = stat.mtime if stat.mtime > @latestmtime
    "\nCACHE:\n" + files.join("\n")

  networks_section: ->
    "\nNETWORK:\n" + @options.networks.join("\n") if @options.networks.length

  fallbacks_section: ->
    unless @options.fallbacks == null
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
    if @options.manifest_path == req.url
      @latestmtime = new Date() if @latestmtime == 0
      manifest = @response()
      res.writeHead 200,
        "Content-Type": "text/cache-manifest"
        "Last-Modified": @latestmtime.toUTCString()
        "Content-Length": manifest.length
      res.end manifest
    else
      next()
