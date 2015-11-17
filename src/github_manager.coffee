_ = require 'lodash'

Log = require './log'
UserInput = require './user_input'
User = require './user'
GitRemote = require './git_remote'

module.exports =
class GitHubManager
  @choose: (opts) =>
    @oldOrNewRepo(opts).then (name) ->
      _.assign(opts, repo: name)

  @oldOrNewRepo: (opts) ->
    GitRemote.exists().then (repo) =>
      if repo.exists
        Log.p "Using your existing GitHub repository: #{repo.name}"
        repo.name
      else
        @new(opts.slug)

  @new: (slug) ->
    User.get().then (user) ->
      UserInput.repo("#{user.github_username}/#{slug}")
