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
    console.log('fucked')
    console.log(opts)
    @execRequest(opts.slug, opts.repo).catch (resp) ->
      return _.assign(opts, slug: null) if resp.error == 'app-exists'

  @get: ->
    new Promise (resolve, reject) =>
      GitRepository.exists().then (repo) =>
        return resolve(exists: false) unless repo.exists

        @backend(repo.name).then(resolve)

  @backend: (repo) ->
    new Promise (resolve, reject) =>
      # mock
      return resolve(exists: false, repo: repo, slug: 'hello')
      Authorized.request url: Urls.websiteExists(), qs: { repo: repo }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve(exists: resp.body.exists, repo: repo, slug: resp.body.slug)

  @execRequest: (slug, repo) ->
    new Promise (resolve, reject) =>
      reject(slug: slug, repo: repo, error: 'app-exists')
      Authorized.request url: Urls.publishNewWebsite(), qs: { repo: repo, slug: slug }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        # if resp.body.success
        #   resolve(opts)
        # else
        reject(slug: slug, repo: repo, error: 'app-exists')
