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
class GitHubManager
  @repo: (slug) =>
    @noRepo(slug)
      .then(@newRepo)
      .catch(@reuse)

  @newRepo: UserInput.repo

  @reuse: (err) =>
    ReuseRepoContinuousDeployment.start(err.repo, err.slug).catch(=> @newRepo(err.slug))

  # TODO: select only GitHub repo
  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  @noRepo: (slug) ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ['--verbose'], (err, resp) ->
        return reject(err) if err

        existing_repo = resp.match(GITHUB_REPO_REGEX)[1]
        return reject(repo: existing_repo, slug: slug) if existing_repo

        resolve(slug)
