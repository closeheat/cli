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
        url: 'http://example-slug.closeheatapp.com'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        Opening your website at http://example-slug.closeheatapp.com.
        """
      done()

  it 'should say when it does not exist', (done) ->
    @timeout(5000)
    @api.routes.post '/apps/exists', (req, res) ->
      res.send
        exists: false

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        No published website from this folder exists.
        To publish this folder, type: closeheat publish
        """
      done()
