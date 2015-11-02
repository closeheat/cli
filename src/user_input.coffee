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
        message: 'What subdomain would you like? [example: HELLO.closeheatapp.com]'
        name: 'slug'
        default: suggested
      }, (answer) =>
        resolve(answer.slug)

  @repo: (suggested) ->
    new Promise (resolve, reject) =>
      # show as example instead of default. inquirer / in defaults bug
      inquirer.prompt {
        message: "How will you name a new GitHub repository? (example: #{suggested})"
        name: 'repo'
      }, (answer) =>
        resolve(answer.repo.replace(' ', ''))
