fs = require 'fs'
path = require 'path'
nock = require 'nock'
express = require 'express'
_ = require 'lodash'
proxyquire =  require('proxyquire')
expect = require('chai').expect
command = require './helpers/command'

TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'list', ->
  describe 'with token', ->
    beforeEach ->
      TestConfig.init()
      TestConfig.rm()
      Config.update('access_token', 'existing-token')

      @app = express()
      @server = @app.listen(1234)

    afterEach ->
      @server.close()

    it 'authorized', (done) ->
      @app.get '/apps', (req, res) ->
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
      @app.get '/apps', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('list').then (stdout) ->
        expect(stdout).to.match(/You need to log in for that./)
        expect(stdout).to.match(/Type/)
        expect(stdout).to.match(/closeheat login/)
        expect(stdout).to.match(/or open/)
        expect(stdout).to.match(/to do it swiftly./)
        done()
