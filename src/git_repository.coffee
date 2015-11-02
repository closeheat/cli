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

module.exports =
class GitRepository
  @ensureRemote: (opts) =>
    @exists().then (repo) =>
      return _.assign(opts, remote: repo.name) if repo.exists

      @addOriginRemote(opts.repo_url).then ->
        _.assign(opts, remote: opts.repo_url)

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

        repo_match = resp.match(GITHUB_REPO_REGEX)
        return resolve(exists: false) unless repo_match

        resolve(exists: true, name: repo_match[1])
