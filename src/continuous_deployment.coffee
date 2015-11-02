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
Website = require './website'
GitRepository = require './git_repository'

shepherd = require("shepherd")

module.exports =
class ContinuousDeployment
  constructor: ->
    @git = new Git()

  start: ->
    @ensureNoWebsite().then =>
      Log.p('You are about to publish a new website.')
      @run().then(@success)

  steps: ->
    [
      { key: 'slug', fn: SlugManager.choose }
      { key: 'repo', fn: GitHubManager.choose }
      { key: 'website', fn: Website.create }
      { key: 'remote', fn: GitRepository.ensureRemote }
    ]

  unfullfilledSteps: (opts) ->
    _.select @steps(), (obj) ->
      !opts[obj.key]

  run: (opts = {}) ->
    return opts if _.isEmpty(@unfullfilledSteps(opts))

    runner = Promise.reduce @unfullfilledSteps(opts), (new_opts, obj) ->
      obj.fn(new_opts).then (result) ->
        result
    , {}

    runner.then (opts) =>
      @run(opts)

  ensureNoWebsite: (data) ->
    Website.get().then (website) =>
      return unless website.exists

      @exists(website)

  exists: (website) ->
    Log.p "Hey there! This folder is already published to closeheat."
    Log.p "It is available at #{Color.violet("#{website.slug}.closeheatapp.com")}."
    Log.p "You can open it swiftly by typing #{Color.violet('closeheat open')}."
    Log.br()
    Log.p "It has a continuous deployment setup from GitHub at #{website.repo}"
    Log.br()
    Log.p "Anyways - if you'd like to publish your current code changes, just type:"
    Log.p Color.violet('closeheat quick-publish')
    Log.p "Doing that will commit and push all of your changes to the GitHub repository and publish it."
    process.exit()

  success: (opts) ->
    slug = opts.slug
    repo = opts.repo
    # url = opts.url

    Log.p 'Success!'
    Log.p "Your website #{Color.violet("#{slug}.closeheatapp.com")} is now published."
    Log.br()
    Log.p "GitHub repository #{repo} is setup for continuous deployment."
    Log.p "Every change to master branch will be immediately published."
    Log.br()
    Log.p "The logs of each deploy are available with #{Color.violet('closeheat log')}."
    Log.p "It's useful to have them right after your #{Color.violet('git push')} with #{Color.violet('git push origin master && closeheat log')}"
    Log.br()
    Log.p "To set up a custom domain or change a public directory type:"
    # Just opens http://app.closeheat.com/apps/app-name/settings
    Log.code 'closeheat settings'
