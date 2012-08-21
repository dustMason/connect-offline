#process.env.NODE_ENV = 'development'
#path = require 'path'
request = require 'request'
offline = require('../lib/offline.js')
manifest_path = 'application.manifest'


exports['Serves a basic cache manifest file with no extras'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path)
  app.listen 3590
  request "http://localhost:3590/#{manifest_path}", (err, res, body) ->
    throw err if err
    test.strictEqual body.search("NETWORK:"), -1
    test.strictEqual body.search("FALLBACK:"), -1
    console.log body
    test.done()
    app.close()

exports['Serves a cache manifest file with a network section'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path, networks: ['/'])
  app.listen 3590
  request "http://localhost:3590/#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("NETWORK:") > 0)
    test.done()
    app.close()

exports['Serves a cache manifest file with a fallbacks section'] = (test) ->
  app = require('connect').createServer()
  app.use offline(manifest_path: manifest_path, fallbacks: {'/main.py':'/static.html','*.html':'/offline.html'})
  app.listen 3590
  request "http://localhost:3590/#{manifest_path}", (err, res, body) ->
    throw err if err
    test.ok(body.search("FALLBACK:") > 0)
    test.done()
    app.close()
