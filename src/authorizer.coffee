fs = require 'fs'
homePath = require('home-path')
inquirer = require 'inquirer'
request = require 'request'
Promise = require 'bluebird'

Log = require './log'
Urls = require './urls'

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
      @getToken(answers).then(cb).catch (status) =>
        if status == 401
          Log.error("Wrong password or email. Please try again")
          @login()
        else
          Log.backendError()

  getToken: (answers) ->
    new Promise (resolve, reject) =>
      request url: Urls.getToken(), qs: answers, method: 'post', json: true, (err, resp) =>
        if resp.statusCode == 200
          @saveToken(resp.body.access_token)
          resolve()
        else
          reject(resp.statusCode)
