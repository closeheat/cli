inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'

Urls = require './urls'
Authorized = require './authorized'
Log = require './log'

module.exports =
class Initializer
  init: ->
    default_app_name = path.basename(process.cwd())

    new Promise (resolve, reject) ->
      inquirer.prompt {
        message: 'How should we name your GitHub repo?'
        name: 'name'
        default: default_app_name
      }, (answer) ->
        Log.br()
        Pusher = require './pusher'
        pusher = new Pusher(answer.name, process.cwd())
        pusher.push()
