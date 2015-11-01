inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
inquirer = require 'inquirer'
_ = require 'lodash'

Urls = require './urls'
SlugManager = require './slug_manager'
Log = require './log'
UserInput = require './user_input'
User = require './user'
Git = require './git'
GitRepository = require './git_repository'

module.exports =
class GitHubManager
  @choose: (opts) =>
    @oldOrNewRepo(opts).then (name) ->
      _.assign(opts, repo: name)

  @oldOrNewRepo: (opts) ->
    GitRepository.exists().then (repo) =>
      if repo.exists
        Log.p "Using your existing GitHub repository: #{repo.name}"
        repo.name
      else
        @new(opts.slug)

  @new: (slug) ->
    User.get().then (user) ->
      UserInput.repo("#{user.name}/#{slug}")
