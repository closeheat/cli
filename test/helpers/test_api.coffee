express = require 'express'
bodyParser = require 'body-parser'

module.exports =
class TestApi
  constructor: ->
    @routes = express()
    @routes.use(bodyParser.urlencoded(extended: false))
    @routes.use(bodyParser.json())

  start: ->
    @routes.listen(1234)
