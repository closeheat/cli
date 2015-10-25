expect = require('chai').expect

TestConfig = require './helpers/test_config'
TestApi = require './helpers/test_api'
Config = require '../src/config'
command = require './helpers/command'

describe 'list', ->
  describe 'with token', ->
    beforeEach ->
      TestConfig.init()
      TestConfig.rm()
      Config.update('access_token', 'existing-token')
      @api = new TestApi()
      @server = @api.start()

    afterEach ->
      @server.close()

    it 'authorized', (done) ->
      @api.routes.get '/apps', (req, res) ->
        res.send apps: [
          {
            name: 'Example app',
            slug: 'example-slug',
          }
        ]

      command('list').then (stdout) ->
        expect(stdout).to.match(/Getting information about your deployed apps./)
        expect(stdout).to.match(/You have 1 apps deployed./)
        expect(stdout).to.match(/Name/)
        expect(stdout).to.match(/Clone command/)
        expect(stdout).to.match(/Example app/)
        expect(stdout).to.match(/closeheat clone example-slug/)
        expect(stdout).to.match(/Edit any of your apps by cloning it with:/)
        expect(stdout).to.match(/closeheat clone your-awesome-app/)
        done()

    it 'unauthorized', (done) ->
      @api.routes.get '/apps', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('list').then (stdout) ->
        expect(stdout).to.match(/You need to log in for that./)
        expect(stdout).to.match(/Type/)
        expect(stdout).to.match(/closeheat login/)
        expect(stdout).to.match(/or open/)
        expect(stdout).to.match(/to do it swiftly./)
        done()
