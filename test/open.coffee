expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'
assertStdout = require './helpers/assert_stdout'

describe 'open', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  it 'should open app url', (done) ->
    @timeout(5000)
    @api.routes.post '/deploy/slug', (req, res) ->
      res.send slug: 'example-slug'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        Opening your app at http://example-slug.closeheatapp.com.
        """
      done()
