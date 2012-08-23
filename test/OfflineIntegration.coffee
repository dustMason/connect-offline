# TODO
# implement a setUp and tearDown to reset the contents of the fixture files
# with each test.

request = require 'request'
fs = require 'fs'
offline = require('../lib/offline.js')
manifest_path = '/application.manifest'


exports['Serves a basic cache manifest file with no extras'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path)
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("NETWORK:") == -1)
    test.ok(body.search("FALLBACK:") == -1)
    test.done()
    app.close()

exports['Serves a cache manifest file with a network section'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path, networks: ['/'])
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("NETWORK:") > 0)
    test.done()
    app.close()

exports['Serves a cache manifest file with a fallbacks section'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path, fallbacks: {'/main.py':'/static.html','*.html':'/offline.html'})
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("FALLBACK:") > 0)
    test.done()
    app.close()

exports['Accepts a list of files to cache and adds their paths to the manifest'] = (test) ->
  app = require('connect').createServer()
  app.use(offline
    manifest_path: manifest_path
    files: [
      { dir: '/public/css', prefix: '/css/' },
      { dir: '/public/js', prefix: '/js/' }
    ]
  )
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("/css/style.css") > 0)
    test.ok(body.search("/js/hello.js") > 0)
    test.done()
    app.close()

exports['Doesnt touch the cache buster when no files have changed'] = (test) ->
  app = require('connect').createServer()
  app.use(offline
    manifest_path: manifest_path
    files: [
      { dir: '/public/css', prefix: '/css/' },
      { dir: '/public/js', prefix: '/js/' }
    ]
  )
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    old_buster = body.split("\n")[1]
    setTimeout( ->
      request "http://localhost:3590#{manifest_path}", (err, res, newbody) ->
        throw err if err
        new_buster = newbody.split("\n")[1]
        test.ok(old_buster == new_buster)
        test.done()
        app.close()
    , 10)

exports['Keeps the cache buster updated when a file is updated'] = (test) ->
  app = require('connect').createServer()
  app.use(offline
    manifest_path: manifest_path
    files: [
      { dir: '/public/css', prefix: '/css/' },
      { dir: '/public/js', prefix: '/js/' }
    ]
  )
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    old_buster = body.split("\n")[1]
    setTimeout( ->
      fs.appendFileSync('public/css/style.css',"\n/* append */")
      request "http://localhost:3590#{manifest_path}", (err, res, newbody) ->
        throw err if err
        new_buster = newbody.split("\n")[1]
        test.ok(old_buster != new_buster)
        test.done()
        app.close()
    , 10)

exports['Uses fs.watch to keep the cache buster updated when the option is set'] = (test) ->
  app = require('connect').createServer()
  app.use(offline
    manifest_path: manifest_path
    use_fs_watch: true
    files: [
      { dir: '/public/css', prefix: '/css/' },
      { dir: '/public/js', prefix: '/js/' }
    ]
  )
  app.listen 3590
  request "http://localhost:3590#{manifest_path}", (err, res, body) ->
    throw err if err
    old_buster = body.split("\n")[1]
    setTimeout( ->
      fs.appendFileSync('public/css/style.css',"\n/* append */")
      request "http://localhost:3590#{manifest_path}", (err, res, newbody) ->
        throw err if err
        new_buster = newbody.split("\n")[1]
        test.ok(old_buster != new_buster)
        test.done()
        app.close()
    , 10)

