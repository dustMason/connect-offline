# [connect-offline](http://github.com/dustmason/connect-offline)

_ = require('underscore')
fs = require('fs')

module.exports = offline = (options={}) ->

  options.networks ?= []
  options.fallbacks ?= null
  options.files ?= []
  options.manifest_path ?= '/application.manifest'
  options.use_fs_watch ?= false

  connectOffline = module.exports.instance = new ConnectOffline options
  connectOffline.middleware


class ConnectOffline

  constructor: (@options) ->
    @load_file_list()
    @update_latestmtime()
    if @options.use_fs_watch
      @watchers = []
      @watch_files (event,filename)=>
        @latestmtime = new Date() if event == 'change'

  load_file_list: ->
    root = process.cwd()
    @options.files = _.map(@options.files, (set) ->
      set.filenames = fs.readdirSync(root + set.dir)
      set.full_paths = _.map(set.filenames, (filename) ->
        root + set.dir + '/' + filename
      )
      set
    )
    @all_files = _.flatten(_.pluck(@options.files, 'full_paths'))

  update_latestmtime: ->
    @latestmtime ||= 0
    for file in @all_files
      stat = fs.statSync(file)
      @latestmtime = stat.mtime if stat.mtime > @latestmtime

  watch_files: (callback) ->
    for file in @all_files
      @watchers.push fs.watch(file, {persistent: true}, callback)

  header_section: ->
    @update_latestmtime() unless @options.use_fs_watch
    "CACHE MANIFEST\n" + "# " + @latestmtime.getTime()

  cache_section: ->
    relative_paths = []
    for dir in @options.files
      for filename in dir.filenames
        relative_paths.push(dir.prefix + filename)
    "\nCACHE:\n" + relative_paths.join("\n")

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
      @latestmtime = new Date() if @latestmtime == 0 # this happens when no files are given
      manifest = @response()
      res.writeHead 200,
        "Content-Type": "text/cache-manifest"
        "Last-Modified": @latestmtime.getTime()
        "Content-Length": manifest.length
      res.end manifest
    else
      next()
