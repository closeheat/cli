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
    @api.routes.post '/apps/find', (req, res) ->
      res.send
        app:
          exists: true
          slug: 'example-slug'
          url: 'http://example-slug.closeheatapp.com'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        Opening your website at http://example-slug.closeheatapp.com.
        """
      done()

  it 'should say when it does not exist', (done) ->
    @api.routes.post '/apps/find', (req, res) ->
      res.send
        app:
          exists: false

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        No published website from this folder exists.
        To publish this folder, type: closeheat publish
        """
      done()
