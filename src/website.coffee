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
      return @handleProblem(resp, opts) unless resp.success

      _.assign(opts, website: resp.url, repo_url: resp.repo_url)

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
      Authorized.post(Urls.websiteDataFromRepo(), repo: repo).then (resp) ->
        resolve(exists: resp.exists, repo: repo, slug: resp.slug, url: resp.url)

  @execRequest: (slug, repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.publishNewWebsite(), repo: repo, slug: slug).then (resp) ->
        resolve(error_type: resp.error_type, success: resp.success, url: resp.url, repo_url: resp.repo_url)
