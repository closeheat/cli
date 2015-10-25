nixt = require 'nixt'
fs = require 'fs'
path = require 'path'
nock = require 'nock'
express = require 'express'
_ = require 'lodash'
proxyquire =  require('proxyquire')
expect = require('chai').expect
sinon = require 'sinon'

closeheat = './dist/bin/closeheat.js'
home_path = path.join(process.cwd(), 'test', 'fixtures', 'home')
config_path = path.join(home_path, '.closeheat', 'config.json')

List = require '../src/list'
Urls = require '../src/urls'
Authorized = require '../src/authorized'
Log = require '../src/log'
Color = require '../src/color'

assertConfig = (expected) ->
  actual = JSON.parse(fs.readFileSync(config_path).toString())
  expect(actual).to.eql(expected)

cleanConfig = ->
  return unless fs.existsSync(config_path)
  fs.unlinkSync(config_path)

writeConfig = (content) ->
  fs.writeFileSync(config_path, JSON.stringify(content))

class LogRecorder
  constructor: ->
    @records = []

  start: ->
    Log.line = (text) =>
      return unless text

      @records.push(text)
    Log.spin = (text) =>
      return unless text

      @records.push(text)
    Log.logo = ->

    _.each ['orange', 'red', 'redYellow', 'violet', 'bare'], (color) ->
      Color[color] = (text) =>
        text

describe 'list', ->
  describe 'with token', ->
    before ->
      writeConfig(access_token: 'example-token')

    it 'authorized', (done) ->
      app = express()
      app.get '/apps', (req, res) ->
        res.send apps: [
          {
            name: 'Example app',
            slug: 'example-slug',
          }
        ]

      server = app.listen(1234)

      nixt()
        .env('HOME', home_path)
        .run("#{closeheat} list")
        .expect((result) ->
          expect(result.stdout).to.match(/Login successful. Access token saved./)
        )
        .end(-> done())

      server.close()

      # Authorized.request = (opts, cb) ->
      #   cb null,
      #     body: JSON.stringify
      #       apps: [
      #         {
      #           name: 'Example app',
      #           slug: 'example-slug',
      #         }
      #       ]


      # recorder = new LogRecorder()
      # recorder.start()
      #
      # new List().show().then ->
      #   expect(recorder.records[0]).to.match(/Getting information about your deployed apps./)
      #   expect(recorder.records[1]).to.match(/You have 1 apps deployed./)
      #   expect(recorder.records[2]).to.match(/Name          Clone command\n  Example app  closeheat clone example-slug/)
      #   expect(recorder.records[3]).to.match(/Edit any of your apps by cloning it with:/)
      #   expect(recorder.records[4]).to.match(/closeheat clone your-awesome-app/)
      #
      #   done()

    # it 'unauthorized', (done) ->
    #   recorder = new LogRecorder()
    #   recorder.start()
    #
    #   new List().show().then ->
    #     expect(recorder.records[0]).to.match(/Getting information about your deployed apps./)
    #     expect(recorder.records[1]).to.match(/You have 1 apps deployed./)
    #     expect(recorder.records[2]).to.match(/Name          Clone command\n  Example app  closeheat clone example-slug/)
    #     expect(recorder.records[3]).to.match(/Edit any of your apps by cloning it with:/)
    #     expect(recorder.records[4]).to.match(/closeheat clone your-awesome-app/)
    #
    #     done()
    #     server.close()
