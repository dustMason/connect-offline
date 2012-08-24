request = require 'request'
fs = require 'fs'
offline = require('../lib/offline.js')
testCase = require("nodeunit").testCase

# globals
MANIFEST_PATH = '/application.manifest'

module.exports['Basic'] = testCase(

  setUp: (callback) ->
    @app = require('connect').createServer()
    @options = manifest_path: MANIFEST_PATH
    @app.listen 3590
    callback()
  tearDown: (callback) ->
    callback()
    @app.close()

  'Serves a basic cache manifest file with no extras': (test) ->
    @app.use offline(@options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      test.ok(body.search("NETWORK:") == -1)
      test.ok(body.search("FALLBACK:") == -1)
      test.done()

  'Serves a cache manifest file with a network section': (test) ->
    @options.networks = ['/']
    @app.use offline(@options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      test.ok(body.search("NETWORK:") > 0)
      test.done()

  'Serves a cache manifest file with a fallbacks section': (test) ->
    @options.fallbacks =
      'main.py': '/static.html'
      '*.html':'/offline.html'
    @app.use offline(@options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      test.ok(body.search("FALLBACK:") > 0)
      test.done()
)

module.exports['Filesystem'] = testCase(

  setUp: (callback) ->
    # fixtures
    fs.writeFileSync('public/css/style.css','#hello { display: none; }')
    fs.writeFileSync('public/js/hello.js','console.log("hello");')
    @app = require('connect').createServer()
    @options = 
      manifest_path: MANIFEST_PATH
      files: [
        { dir: '/public/css', prefix: '/css/' },
        { dir: '/public/js', prefix: '/js/' }
      ]
    @app.listen 3590
    callback()
  tearDown: (callback) ->
    # fixtures
    fs.writeFileSync('public/css/style.css','#hello { display: none; }')
    fs.writeFileSync('public/js/hello.js','console.log("hello");')
    callback()
    @app.close()

  'Accepts a list of files to cache and adds their paths to the manifest': (test) ->
    @app.use(offline @options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      test.ok(body.search("/css/style.css") > 0)
      test.ok(body.search("/js/hello.js") > 0)
      test.done()

  'Doesnt touch the cache buster when no files have changed': (test) ->
    @app.use(offline @options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      old_buster = body.split("\n")[1]
      setTimeout( ->
        request "http://localhost:3590#{MANIFEST_PATH}", (err, res, newbody) ->
          throw err if err
          new_buster = newbody.split("\n")[1]
          test.ok(old_buster == new_buster)
          test.done()
      , 1000)

  #'Updates the cache buster when a file is modified': (test) ->
    #@app.use(offline @options)
    #request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      #throw err if err
      #old_buster = body.split("\n")[1]
      #setTimeout( ->
        #fs.appendFileSync('public/css/style.css',"\n/* append */")
        #request "http://localhost:3590#{MANIFEST_PATH}", (err, res, newbody) ->
          #throw err if err
          #new_buster = newbody.split("\n")[1]
          #test.ok(old_buster != new_buster)
          #test.done()
      #, 1000)

  'Uses fs.watch to keep the cache buster updated when the option is set': (test) ->
    @options.use_fs_watch = true
    @app.use(offline @options)
    request "http://localhost:3590#{MANIFEST_PATH}", (err, res, body) ->
      throw err if err
      old_buster = body.split("\n")[1]
      setTimeout( ->
        fs.appendFileSync('public/css/style.css',"\n/* append */")
        request "http://localhost:3590#{MANIFEST_PATH}", (err, res, newbody) ->
          throw err if err
          new_buster = newbody.split("\n")[1]
          test.ok(old_buster != new_buster)
          test.done()
      , 1000)

)
