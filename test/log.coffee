expect = require('chai').expect

command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'
TestGit = require './helpers/test_git'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'log', ->
  beforeEach (done) ->
    @api = new TestApi()
    @server = @api.start()
    TestGit.init()
      .then(TestGit.createFile)
      .then(TestGit.addAll)
      .then(TestGit.commit)
      .then(-> TestGit.addRemote())
      .then(-> done())

  afterEach ->
    @server.close()

  it 'should display logs and exit on success', (done) ->
    @timeout(5000)

    @api.routes.post '/apps/find', (req, res) ->
      expect(req.body.repo).to.eql('example-org/example-repo')

      res.send
        app:
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
        closeheat | Testing logs.
        """
      done()
