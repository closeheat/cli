fs = require 'fs'
path = require 'path'
nock = require 'nock'
express = require 'express'
_ = require 'lodash'
proxyquire =  require('proxyquire')
expect = require('chai').expect
command = require './helpers/command'

home_path = path.join(process.cwd(), 'test', 'fixtures', 'home')
config_path = path.join(home_path, '.closeheat', 'config.json')

assertConfig = (expected) ->
  actual = JSON.parse(fs.readFileSync(config_path).toString())
  expect(actual).to.eql(expected)

cleanConfig = ->
  return unless fs.existsSync(config_path)
  fs.unlinkSync(config_path)

writeConfig = (content) ->
  fs.writeFileSync(config_path, JSON.stringify(content))

describe 'list', ->
  describe 'with token', ->
    before ->
      writeConfig(access_token: 'example-token')

      @app = express()
      @server = @app.listen(1234)

    after ->
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
