inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
inquirer = require 'inquirer'

Urls = require './urls'
SlugManager = require './slug_manager'
Log = require './log'
Authorized = require './authorized'
Color = require './color'
GitHubManager = require './github_manager'
GitRemote = require './git_remote'
_ = require 'lodash'
Pusher = require 'pusher-client'

module.exports =
class Website
  @create: (opts) =>
    @execRequest(opts.slug, opts.repo).then((resp) =>
      Log.p "Setting up your website..."

      @waitForBuild(resp.pusher).then =>
        Log.br()
        _.assign(opts, website: resp.app.url, github_repo_url: resp.app.github_repo_url)
    ).catch (e) =>
      return @handleProblem(e.message, opts)

  @waitForBuild: (pusher_data) ->
    new Promise (resolve, reject) =>
      pusher = new Pusher pusher_data.key,
        authEndpoint: pusher_data.auth_endpoint
        auth:
          params:
            api_token: Authorized.token()

      pusher_user_channel = pusher.subscribe(pusher_data.user_key)

      # TODO: guard with timeout
      pusher_user_channel.bind 'app.build', =>
        resolve()

  @handleProblem: (message, opts) ->
    if message == 'slug-exists'
      Log.p "Subdomain #{opts.slug} is already taken. Could you choose another one?"
      return _.assign(opts, slug: null)
    else
      Log.p "Some error happened. Shoot a message to support@closeheat.com."
      process.exit()

  @get: ->
    new Promise (resolve, reject) =>
      GitRemote.exists().then (repo) =>
        return resolve(exists: false) unless repo.exists

        @backend(repo.name).then(resolve)

  @backend: (repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.findApp(), repo: repo).then (resp) ->
        resolve(resp.app)

  @execRequest: (slug, repo) ->
    Authorized.post(Urls.publish(), github_repo: repo, slug: slug)
