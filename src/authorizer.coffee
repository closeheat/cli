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

  # login: (cb = ->) ->
  #   login_questions =  [
  #     {
  #       message: 'Your email address'
  #       name: 'email'
  #       type: 'input'
  #     }
  #     {
  #       message: 'Your password'
  #       name: 'password'
  #       type: 'password'
  #     }
  #   ]
  #
  #   inquirer.prompt login_questions, (answers) =>
  #     @getToken(answers).then(->
  #       Log.br()
  #       cb()
  #     ).catch (resp) =>
  #       if resp.code == 401
  #         Log = require './log'
  #
  #         if resp.status == 'locked'
  #           Log.error('Too many invalid logins. Account locked for 1 hour.', false)
  #           Log.innerError("Check your email for unlock instructions or contact the support at #{Color.violet('closeheat.com/support')}.")
  #         else
  #           Log.error("Wrong password or email. Please try again", false, '', 'login')
  #           @login(cb)
  #
  #       else
  #         Log.backendError()

  getToken: (answers) ->
    new Promise (resolve, reject) =>
      params =
        url: Urls.getToken()
        headers: { 'X-CLI-Version': pkg.version }
        qs: answers
        method: 'post'
        json: true

      request params, (err, resp) =>
        Log.error(err) if err

        if resp.statusCode == 200
          @saveToken(resp.body.access_token)
          resolve()
        else
          reject(code: resp.statusCode, status: resp.body.status)

  forceLogin: (cb) ->
    Log = require './log'
    Log.stop()
    Log.br()
    Log.p Color.redYellow('Please login to closeheat.com to check out your app list.')
    @login(cb)

  unauthorized: (resp) ->
    resp.statusCode == 401

  checkLoggedIn: (resp, cb) ->
    if @unauthorized(resp)
      @forceLogin(cb)
