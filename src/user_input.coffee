inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'

Urls = require './urls'
Authorized = require './authorized'
Log = require './log'

module.exports =
class UserInput
  @slug: (suggested) ->
    new Promise (resolve, reject) =>
      inquirer.prompt {
        message: 'Choose a subdomain - XXX.closeheatapp.com:'
        name: 'slug'
        default: suggested
      }, (answer) =>
        resolve(answer.slug)

  @repo: (suggested) ->
    new Promise (resolve, reject) =>
      inquirer.prompt {
        message: 'Choose a GitHub repository:'
        name: 'repo'
        default: suggested
      }, (answer) =>
        return resolve(suggested) unless answer.repo
        return resolve(answer.repo) if answer.repo.match(/(.*)\/(.*)/)

        Log.p 'Could you provide the repository name in "name/repository" format?'
        resolve()
