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
    open(Urls.loginInstructions()) unless process.env.CLOSEHEAT_TEST

  @forceLogin: ->
    Log = require './log'
    Log.stop()
    Log.p Color.redYellow('You need to log in for that.')
    Log.p("Type #{Color.violet('closeheat login')} to do it swiftly.")
    process.exit()

  @unauthorized: (resp) ->
    resp.statusCode == 401

  @gracefulUnauthorized: (resp) ->
    return unless resp[0]

    @forceLogin() if @unauthorized(resp[0])

  ensureGitHubAuthorized: ->
    new Promise (resolve, reject) ->
      Authorized.request url: Urls.githubAuthorized(), method: 'get', (err, resp) ->
        authorized = JSON.parse(resp.body).authorized

        if authorized
          resolve()
        else
          Log = require './log'
          Log.error('GitHub not authorized', false)
          Log.innerError "We cannot set you up for deployment because you did not authorize GitHub.", false
          Log.br()
          Log.innerError "Visit #{Urls.authorizeGitHub()} and rerun the command."
