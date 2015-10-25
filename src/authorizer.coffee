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
    overriden = @accessTokenExists()

    config = { access_token: access_token }
    Config.update('access_token', access_token)

    Log = require './log'

    if overriden
      Log.doneLine('Login successful. New access token saved.')
    else
      Log.doneLine('Login successful. Access token saved.')

  accessToken: ->
    Config.fileContents().access_token

  accessTokenExists: ->
    Config.fileContents().access_token && Config.fileContents().access_token != 'none'

  login: (token) ->
    return @saveToken(token) if token

    if @accessTokenExists()
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
    open(Urls.loginInstructions()) if global.BROWSER

  forceLogin: (cb) ->
    Log = require './log'
    Log.stop()
    Log.p Color.redYellow('You need to log in for that.')
    Log.p("Type #{Color.violet('closeheat login')} or open #{Color.violet(Urls.loginInstructions())} to do it swiftly.")

  unauthorized: (resp) ->
    resp.statusCode == 401

  checkLoggedIn: (resp, cb) ->
    @forceLogin(cb) if @unauthorized(resp)
