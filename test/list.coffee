nixt = require 'nixt'
fs = require 'fs'
path = require 'path'
nock = require 'nock'
_ = require 'lodash'
proxyquire =  require('proxyquire')
expect = require('chai').expect

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
      Authorized.request = (opts, cb) ->
        cb null,
          body: JSON.stringify
            apps: [
              {
                name: 'Example app',
                slug: 'example-slug',
              }
            ]


      recorder = new LogRecorder()
      recorder.start()

      new List().show().then ->
        expect(recorder.records[0]).to.match(/Getting information about your deployed apps./)
        expect(recorder.records[1]).to.match(/You have 1 apps deployed./)
        expect(recorder.records[2]).to.match(/Name          Clone command\n  Example app  closeheat clone example-slug/)
        expect(recorder.records[3]).to.match(/Edit any of your apps by cloning it with:/)
        expect(recorder.records[4]).to.match(/closeheat clone your-awesome-app/)

        done()

    # it 'unauthorized', (done) ->
    #   Authorized.request = (opts, cb) ->
    #     cb null,
    #       status: 401
    #       body: JSON.stringify
    #         message: 'Unauthorized'
    #
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
