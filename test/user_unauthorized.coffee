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

describe 'graceful when user cli is not authorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')

  after ->
    @server.close()

  it 'list', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('list').then (stdout) ->
      assertStdout stdout,
        """
        - Getting information about your websites.
        #{gracefulUnauthorized}
        """
      done()

  it 'clone', (done) ->
    @api.routes.get '/apps/example-slug', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('clone example-slug').then (stdout) ->
      assertStdout stdout,
        """
        - Getting application data for example-slug.
        #{gracefulUnauthorized}
        """
      done()

  describe 'log', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('log').then (stdout) ->
        assertStdout stdout,
          """
          TEST: Executing 'git remote --verbose'
          #{gracefulUnauthorized}
          """
        done()

    it 'builds unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.send slug: 'example-slug'

      @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('log').then (stdout) ->
        assertStdout stdout,
          """
          TEST: Executing 'git remote --verbose'
          #{gracefulUnauthorized}
          """
        done()

  it 'open', (done) ->
    @api.routes.post '/deploy/slug', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('open').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        #{gracefulUnauthorized}
        """
      done()

  describe 'deploy', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('deploy').then (stdout) ->
        assertStdout stdout,
          """
          - Deploying the app to closeheat.com via GitHub.
          TEST: Executing 'git add .'
            All files added.
          TEST: Executing 'git commit m: true \'Quick deploy\''
            Files commited.
            Pushing to GitHub.
          TEST: Executing 'git remote '
          TEST: Executing 'git symbolic-ref --short HEAD'
          TEST: Executing 'git push origin example-branch'
            Pushed to example-branch branch on GitHub.
          TEST: Executing 'git remote --verbose'
          #{gracefulUnauthorized}
          """
        done()

    it 'builds unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.send slug: 'example-slug'

      @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('deploy').then (stdout) ->
        assertStdout stdout,
          """
          - Deploying the app to closeheat.com via GitHub.
          TEST: Executing 'git add .'
            All files added.
          TEST: Executing 'git commit m: true \'Quick deploy\''
            Files commited.
            Pushing to GitHub.
          TEST: Executing 'git remote '
          TEST: Executing 'git symbolic-ref --short HEAD'
          TEST: Executing 'git push origin example-branch'
            Pushed to example-branch branch on GitHub.
          TEST: Executing 'git remote --verbose'
          #{gracefulUnauthorized}
          """
        done()
