fs = require 'fs'
path = require 'path'
expect = require('chai').expect
Urls = require '../src/urls'

command = require './helpers/command'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

describe 'login', ->
  beforeEach ->
    TestConfig.init()
    TestConfig.rm()

  describe 'have a token', ->
    it 'blank slate', (done) ->
      command('login example-token').then (stdout) ->
        expect(stdout).to.match(/Login successful. Access token saved./)
        expect(Config.fileContents()).to.eql(access_token: 'example-token')
        done()

    it 'override existing token', (done) ->
      Config.update('access_token', 'existing-token')

      command('login example-token').then (stdout) ->
        expect(stdout).to.match(/Login successful. New access token saved./)
        expect(Config.fileContents()).to.eql(access_token: 'example-token')
        done()

  describe 'no token', ->
    it 'not logged in', (done) ->
      command('login').then (stdout) ->
        expect(stdout).to.match(/Log in at/)
        expect(stdout).to.match(/in your browser./)
        done()

    it 'logged in already', (done) ->
      Config.update('access_token', 'existing-token')

      command('login').then (stdout) ->
        expect(stdout).to.match(/You are already logged in./)
        expect(stdout).to.match(/Log in with another account here:/)
        done()
