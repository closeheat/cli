expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'
assertStdout = require './helpers/assert_stdout'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

gracefulUnauthorized =
  """
  You need to log in for that.
  Type closeheat login or open http://app.closeheat.com/api/login to do it swiftly.
  """

describe 'graceful when GitHub not authorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')

    @api.routes.post '/apps/exists', (req, res) ->
      res.status(401).send
        type: 'github-unauthorized'
        message: 'Unauthorized'

  after ->
    @server.close()

  it 'publish', (done) ->
    @timeout(5000)

    command('publish').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        ERROR | GitHub not authorized
                We cannot set you up for deployment because you did not authorize GitHub.
                Visit http://app.closeheat.com/authorize-github and rerun the command.
        """
      done()
