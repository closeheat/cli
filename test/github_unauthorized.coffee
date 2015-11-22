expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'
assertStdout = require './helpers/assert_stdout'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

gracefulUnauthorized =
  """
  You need to log in for that.
  Type closeheat login to do it swiftly.
  """

describe 'graceful when GitHub not authorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

    @api.routes.post '/apps/find', (req, res) ->
      res.status(401).send
        type: 'github-unauthorized'
        message: 'Unauthorized'

  after ->
    @server.close()

  it 'publish', (done) ->
    command('publish').then (stdout) ->
      assertStdout stdout,
        """
        ERROR | GitHub not authorized
                We cannot set you up for deployment because you did not authorize GitHub.
                Run closeheat auth-github and rerun the command.
        """
      done()
