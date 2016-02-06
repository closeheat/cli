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
        Log.br()
        Log.p "This folder is not in a GitHub repository."
        Log.p "Set up GitHub repository first: https://github.com/new"
        process.exit()
