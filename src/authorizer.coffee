fs = require 'fs'
inquirer = require 'inquirer'
request = require 'request'
pkg = require '../package.json'
Promise = require 'bluebird'
open = require 'open'

Urls = require './urls'
Color = require './color'
Config = require './config'

module.exports =
class Authorizer
  saveToken: (access_token) ->
    overriden = Config.fileContents().access_token != 'none'

    config = { access_token: access_token }
    Config.update('access_token', access_token)

    Log = require './log'

    if overriden
      Log.doneLine('Login successful. New access token saved.')
    else
      Log.doneLine('Login successful. Access token saved.')

  accessToken: ->
    Config.fileContents().access_token

  login: (token) ->
    return @saveToken(token) if token

    if @accessToken() != 'none'
      @youreLoggedIn()
    else
      @openLogin()

  youreLoggedIn: ->
    Log = require './log'

    Log.doneLine('You are already logged in.')
    Log.inner("Log in with another account here: #{Urls.loginInstructions()}")

  openLogin: ->
    Log = require './log'

    Log.doneLine("Log in at #{Urls.loginInstructions()} in your browser.")
    open(Urls.loginInstructions())

  forceLogin: (cb) ->
    Log = require './log'
    Log.stop()
    Log.br()
    Log.p Color.redYellow('Please login to closeheat.com to check out your app list.')
    # @openLogin()

  unauthorized: (resp) ->
    resp.statusCode == 401

  checkLoggedIn: (resp, cb) ->
    @forceLogin(cb) if @unauthorized(resp)
