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
        message: 'What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later)'
        name: 'slug'
        default: suggested
      }, (answer) =>
        resolve(answer.slug)

  @repo: (suggested) ->
    new Promise (resolve, reject) =>
      inquirer.prompt {
        message: 'What is the GitHub repository would you like to create for this website? Ex. Nedomas/NAME?'
        name: 'repo'
        default: suggested
      }, (answer) =>
        resolve(answer.repo)

  @reuseRepo: (repo_name) ->
    new Promise (resolve, reject) =>
      inquirer.prompt({
        message: "Would you like to use your existing #{repo_name} GitHub repository repo for continuos delivery?"
        type: 'confirm'
        name: 'reuse'
      }, (answer) ->
        resolve(answer.reuse)
      )
