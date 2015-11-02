fs = require 'fs'
inquirer = require 'inquirer'
request = require 'request'
pkg = require '../package.json'
Promise = require 'bluebird'
open = require 'open'

Urls = require './urls'
Color = require './color'
Config = require './config'
Authorized = require './authorized'

module.exports =
class Authorizer
  saveToken: (access_token) ->
    overriden = @accessToken()

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

    if @accessToken()
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
    open(Urls.loginInstructions()) unless process.env.CLOSEHEAT_TEST
