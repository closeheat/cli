inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
inquirer = require 'inquirer'
_ = require 'lodash'

Urls = require './urls'
SlugManager = require './slug_manager'
Log = require './log'
UserInput = require './user_input'
Git = require './git'
ReuseRepoContinuousDeployment = require './reuse_repo_continuous_deployment'

module.exports =
class GitRepository
  # exists: ->
  #   @gitHubRemote
  #   @existing().then( (existing) ->
  #     @reuse(slug, existing)
  #   ).catch -> @newRepo(slug)
  #
  # newRepo: UserInput.repo
  #
  # reuse: (slug, existing) =>
  #   ReuseRepoContinuousDeployment.start(existing, slug).catch(=> @newRepo(slug))
  #
  @addOriginRemote: (url) ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ["add origin #{url}"], (err, resp) ->
        return reject(err) if err

        resolve(resp)

  # TODO: select only GitHub repo
  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  @exists: ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ['--verbose'], (err, resp) ->
        return reject(err) if err

        existing_repo = resp.match(GITHUB_REPO_REGEX)[1]

        resolve(exists: !!existing_repo, name: existing_repo)
