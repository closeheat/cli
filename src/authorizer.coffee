fs = require 'fs'
homePath = require('home-path')
inquirer = require 'inquirer'
request = require 'request'
Promise = require 'bluebird'

Log = require './log'
Urls = require './urls'
Color = require './color'

module.exports =
class Authorizer
  saveToken: (access_token) ->
    config = { access_token: access_token }
    fs.writeFileSync(@configFile(), JSON.stringify(config))
    Log.doneLine('Access token saved.')

  accessToken: ->
    JSON.parse(fs.readFileSync(@configFile()).toString()).access_token

  configFile: ->
    "#{homePath()}/.closeheat/config.json"

  login: (cb = ->) ->
    login_questions =  [
      {
        message: 'Your email address'
        name: 'email'
        type: 'input'
      }
      {
        message: 'Your password'
        name: 'password'
        type: 'password'
      }
    ]

    inquirer.prompt login_questions, (answers) =>
      @getToken(answers).then(->
        Log.br()
        cb()
      ).catch (resp) =>
        if resp.code == 401
          if resp.status == 'locked'
            Log.error('Too many invalid logins. Account locked for 1 hour.')
            Log.innerError("Check your email for unlock instructions or contact the support at #{Color.violet('closeheat.com/support')}.")
          else
            Log.error("Wrong password or email. Please try again")
            @login(cb)

        else
          Log.backendError()

  getToken: (answers) ->
    new Promise (resolve, reject) =>
      request url: Urls.getToken(), qs: answers, method: 'post', json: true, (err, resp) =>
        if resp.statusCode == 200
          @saveToken(resp.body.access_token)
          resolve()
        else
          reject(code: resp.statusCode, status: resp.body.status)

  forceLogin: (cb) ->
    Log.stop()
    Log.br()
    Log.p Color.redYellow('Please login to closeheat.com to check out your app list.')
    @login(cb)

  unauthorized: (resp) ->
    resp.statusCode == 401
