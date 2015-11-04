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

describe 'graceful when user cli is not authorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

  after ->
    @server.close()

  it 'list', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.status(401).send
        type: 'user-unauthorized'
        message: 'Unauthorized'

    command('list').then (stdout) ->
      assertStdout stdout,
        """
        - Getting information about your websites.
        #{gracefulUnauthorized}
        """
      done()

  it 'clone', (done) ->
    @api.routes.post '/apps/find', (req, res) ->
      res.status(401).send
        type: 'user-unauthorized'
        message: 'Unauthorized'

    command('clone example-slug').then (stdout) ->
      assertStdout stdout,
        """
        - Getting website information for example-slug.
        #{gracefulUnauthorized}
        """
      done()

  describe 'log', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/apps/find', (req, res) ->
        res.status(401).send
          type: 'user-unauthorized'
          message: 'Unauthorized'

      command('log').then (stdout) ->
        assertStdout stdout,
          """
          #{gracefulUnauthorized}
          """
        done()

    it 'builds unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/apps/find', (req, res) ->
        res.send slug: 'example-slug'

      @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
        res.status(401).send
          type: 'user-unauthorized'
          message: 'Unauthorized'

      command('log').then (stdout) ->
        assertStdout stdout,
          """
          #{gracefulUnauthorized}
          """
        done()

  it 'open', (done) ->
    @api.routes.post '/apps/find', (req, res) ->
      res.status(401).send
        type: 'user-unauthorized'
        message: 'Unauthorized'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        #{gracefulUnauthorized}
        """
      done()

  describe 'deploy', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)

      @api.routes.post '/apps/find', (req, res) ->
        res.status(401).send
          type: 'user-unauthorized'
          message: 'Unauthorized'

      command('publish').then (stdout) ->
        assertStdout stdout,
          """
          #{gracefulUnauthorized}
          """
        done()
