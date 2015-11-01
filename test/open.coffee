expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'
assertStdout = require './helpers/assert_stdout'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'open', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')

  afterEach ->
    @server.close()

  it 'should open app url', (done) ->
    @timeout(5000)
    @api.routes.post '/apps/exists', (req, res) ->
      res.send
        exists: true
        slug: 'example-slug'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        Opening your app at http://example-slug.closeheatapp.com.
        """
      done()
