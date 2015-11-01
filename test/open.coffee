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

  afterEach ->
    @server.close()

  it 'should open app url', (done) ->
    @api.routes.post '/apps/get_from_repo', (req, res) ->
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
    @api.routes.post '/apps/get_from_repo', (req, res) ->
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
