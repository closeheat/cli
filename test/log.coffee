expect = require('chai').expect

command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'log', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  it 'should display logs and exit on success', (done) ->
    @timeout(5000)

    @api.routes.post '/apps/find', (req, res) ->
      expect(req.body.repo).to.eql('example-org/example-repo')

      res.send
        exists: true
        slug: 'example-slug'

    @api.routes.post '/apps/example-slug/builds/for_cli', (req, res) ->
      res.send
        build:
          status: 'success'
          log: [
            {
              message: 'Testing logs.'
            }
          ]

    command('log').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
          closeheat | Testing logs.
        """
      done()
