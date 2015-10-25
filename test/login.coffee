nixt = require 'nixt'
fs = require 'fs'
path = require 'path'
expect = require('chai').expect
Urls = require '../src/urls'
# assert = require 'assert'

closeheat = './dist/bin/closeheat.js'
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

describe 'login', ->
  describe 'have a token', ->
    before ->
      cleanConfig()

    it 'blank slate', (done) ->
      nixt()
        .env('HOME', home_path)
        .run("#{closeheat} login example-token")
        .expect((result) ->
          expect(result.stdout).to.match(/Login successful. Access token saved./)
        )
        .end ->
          assertConfig(access_token: 'example-token')
          done()

    it 'override existing token', (done) ->
      writeConfig(access_token: 'existing-token')

      nixt()
        .env('HOME', home_path)
        .run("#{closeheat} login example-token")
        .expect((result) ->
          expect(result.stdout).to.match(/Login successful. New access token saved./)
        )
        .end ->
          assertConfig(access_token: 'example-token')
          done()

  describe 'no token', ->
    before ->
      cleanConfig()

    it 'not logged in', (done) ->
      nixt()
        .run("#{closeheat} login")
        .expect((result) ->
          expect(result.stdout).to.match(/Login successful. Access token saved./)
        )
        .end(-> done())

    it 'logged in already', (done) ->
      writeConfig(access_token: 'existing-token')

      nixt()
        .env('HOME', home_path)
        .run("#{closeheat} login")
        .expect((result) ->
          expect(result.stdout).to.match(/You are already logged in./)
          expect(result.stdout).to.match(/Login with another account here:/)
        )
        .end(-> done())
