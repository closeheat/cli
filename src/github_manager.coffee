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
    get_it = GitRepository.exists().then (repo) =>
      return @reuse(repo.name, opts.slug) if repo.exists

      @new(opts.slug)

    get_it.then (name) ->
      _.assign(opts, repo: name)

  @new: (slug) ->
    User.get().then (user) ->
      UserInput.repo("#{user.name}/#{slug}")

  @reuse: (repo_name, slug) ->
    UserInput.reuseRepo(repo_name).then (reuse) =>
      return @new(slug) unless reuse

      repo_name

  @create: (repo_name) ->
    # do request
    new Promise (resolve, reject) ->
      resolve()
