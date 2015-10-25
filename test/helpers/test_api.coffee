express = require 'express'

module.exports =
class TestApi
  constructor: ->
    @routes = express()

  start: ->
    @routes.listen(1234)
