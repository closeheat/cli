expect = require('chai').expect

TestApi = require './helpers/test_api'
command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'list', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')

  afterEach ->
    @server.close()

  it 'should show one website and instructions', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.send apps: [
        {
          name: 'Example app',
          slug: 'example-slug',
        }
      ]

    command('list').then (stdout) ->
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

  it 'should show deploy instructions when no websites', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.send apps: []

    command('list').then (stdout) ->
      assertStdout stdout,
        """
        - Getting information about your websites.
          You have no websites.
        Publish this folder as a website by typing:
          closeheat deploy your-website-name
        """
      done()
