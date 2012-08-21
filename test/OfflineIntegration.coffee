#process.env.NODE_ENV = 'development'
path = require 'path'
request = require 'request'

app = require('connect').createServer()
offline = require('../lib/offline.js')
#app.use offline path: '/application.manifest'
app.use offline()
app.listen 3590

exports['Serves a cache.manifest file at the correct request URI'] = (test) ->

  request 'http://localhost:3590/application.manifest', (err, res, body) ->
    throw err if err
    expectedBody = '''
    SOME SHIT
    '''
    test.equals body, expectedBody
    test.done()
    app.close()

