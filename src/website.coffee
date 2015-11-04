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
GitRepository = require './git_repository'
_ = require 'lodash'

module.exports =
class Website
  @create: (opts) =>
    @execRequest(opts.slug, opts.repo).then (resp) =>
      # return @handleProblem(resp, opts) unless resp.success

      _.assign(opts, website: resp.url, github_repo_url: resp.github_repo_url)

  @handleProblem: (resp, opts) ->
    if resp.error_type == 'slug-exists'
      Log.p "Subdomain #{opts.slug} is already taken. Could you choose another one?"
      return _.assign(opts, slug: null)
    else
      Log.p "Some error happened: #{JSON.stringify(resp)}"
      process.exit()

  @get: ->
    new Promise (resolve, reject) =>
      GitRepository.exists().then (repo) =>
        return resolve(exists: false) unless repo.exists

        @backend(repo.name).then(resolve)

  @backend: (repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.findApp(), repo: repo).then (resp) ->
        resolve(resp.app)

  @execRequest: (slug, repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.publish(), repo: repo, slug: slug).then (resp) ->
        resolve(resp.app)
