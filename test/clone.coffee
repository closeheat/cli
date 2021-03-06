expect = require('chai').expect

Config = require '../src/config'
command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'
TestConfig = require './helpers/test_config'
TestGit = require './helpers/test_git'

describe 'clone', ->
  beforeEach (done) ->
    @api = new TestApi()
    @server = @api.start()

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')
    TestGit.init().then(-> done())

  afterEach ->
    @server.close()

  it 'without app name should show apps list', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.send apps: [
        {
          name: 'Example app',
          slug: 'example-slug',
        }
      ]

    command('clone').then (stdout) ->
      assertStdout stdout,
        """
        - Getting information about your websites.
          You have 1 websites.
          Name          Clone command
          Example app  closeheat clone example-slug
        Edit any of your websites by cloning it with:
          closeheat clone awesome-website
        """
      done()

  # it 'with app name', (done) ->
  #   @api.routes.post '/apps/find', (req, res) ->
  #     res.send
  #       app:
  #         exists: true
  #         github_repo: 'example/repo'
  #         default_branch: 'example-branch'
  #         slug: 'example-slug'
  #
  #   command('clone example-slug').then (stdout) ->
  #     assertStdout stdout,
  #       """
  #       - Getting website information for example-slug.
  #       - Cloning GitHub repository from example\/repo.
  #       TEST: Executing 'git clone git@github.com:example\/repo.git example-slug'
  #         Cloned the app code to directory 'example-slug'.
  #       The quickest way to deploy changes to closeheat.com and GitHub is with:
  #         closeheat deploy
  #       For more awesome tricks type:
  #         closeheat help
  #       """
  #     done()

  it 'with invalid app name', (done) ->
    @timeout(5000)
    @api.routes.post '/apps/find', (req, res) ->
      res.send
        app:
          exists: false

    command('clone example-slug').then (stdout) ->
      assertStdout stdout,
        """
        - Getting website information for example-slug.
        ERROR | Website named 'example-slug' does not exist.
        """
      done()
