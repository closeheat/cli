expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'
assertStdout = require './helpers/assert_stdout'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'graceful when GitHub not authorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

    @api.routes.post '/suggest/slug', (req, res) ->
      res.status(401).send
        type: 'github-unauthorized'
        message: 'Unauthorized'

  after ->
    @server.close()

  it 'publish', (done) ->
    command('publish').then (stdout) ->
      assertStdout stdout,
        """
        You are about to publish a new website.
        You need to authorize GitHub for that.
        Type closeheat auth-github to do it.
        And rerun your last command aftewards.
        """
      done()
