Promise = require 'bluebird'
inquirer = require 'inquirer'
_ = require 'lodash'
open = require 'open'
fs = require 'fs.extra'

Git = require './git'
Initializer = require './initializer'
Authorized = require './authorized'
Authorizer = require './authorizer'
Urls = require './urls'
DeployLog = require './deploy_log'

Log = require './log'
Color = require './color'
Notifier = require './notifier'

SlugManager = require './slug_manager'
GitHubManager = require './github_manager'
AppManager = require './app_manager'

module.exports =
class ContinuousDeployment
  constructor: ->
    @git = new Git()

  start: ->
    Log.p('You are about to publish a new website.')
    @configure()

  configure: ->
    SlugManager.choose().then (slug) =>
      GitHubManager.repo(slug).then (repo) =>
        AppManager.create(slug, repo)
          .then(@success)
          .catch(@exists)

  exists: (result) ->
    Log.p "Hey there! This folder is already published to closeheat."
    Log.p "It is available at #{Color.violet("#{result.slug}.closeheatapp.com")}."
    Log.p "You can open it swiftly by typing #{Color.violet('closeheat open')}."
    Log.br()
    Log.p "It has a continuous deployment setup from GitHub at #{result.repo}"
    Log.br()
    Log.p "Anyways - if you'd like to publish your current code changes, just type:"
    Log.p Color.violet('closeheat quick-publish')
    Log.p "Doing that will commit and push all of your changes to the GitHub repository and publish it."
