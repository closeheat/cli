expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'

expectGracefulUnauthorized = (stdout) ->
  expect(stdout).to.match(/You need to log in for that./)
  expect(stdout).to.match(/Type/)
  expect(stdout).to.match(/closeheat login/)
  expect(stdout).to.match(/or open/)
  expect(stdout).to.match(/to do it swiftly./)

describe 'graceful when unauthorized', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  it 'list', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('list').then (stdout) ->
      expect(stdout).to.match(/Getting information about your websites./)
      expectGracefulUnauthorized(stdout)
      done()
