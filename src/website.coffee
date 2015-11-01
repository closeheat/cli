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
    @execRequest(opts.slug, opts.repo).then (resp) ->
      _.assign(opts, website: resp.url, repo_url: resp.repo_url)
    .catch (resp) ->
      return _.assign(opts, slug: null) if resp.error == 'app-exists'

  @get: ->
    new Promise (resolve, reject) =>
      GitRepository.exists().then (repo) =>
        return resolve(exists: false) unless repo.exists

        @backend(repo.name).then(resolve)

  @backend: (repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.websiteData(), repo: repo).then (resp) ->
        resolve(exists: resp.exists, repo: repo, slug: resp.slug, url: resp.url)

  @execRequest: (slug, repo) ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.publishNewWebsite(), repo: repo, slug: slug).then (resp) ->
        # reject(slug: slug, repo: repo, error: 'app-exists')
        resolve(url: resp.url, repo_url: resp.repo_url)
