Promise = require 'bluebird'
_ = require 'lodash'
Git = require 'git-wrapper'

module.exports =
class GitRemote
  @ensure: (opts) =>
    @exists().then (github_repo) =>
      return _.assign(opts, remote: github_repo.name) if github_repo.exists

      @addOrigin(opts.github_repo_url).then ->
        _.assign(opts, remote: opts.github_repo_url)

  @addOrigin: (url) ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ["add origin #{url}"], (err, resp) ->
        return reject(err) if err

        resolve(resp)

  # TODO: select only GitHub repo
  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  @exists: ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ['--verbose'], (err, resp) ->
        if err
          if err.message.match(/Not a git repository/)
            return resolve(exists: false)
          else
            return reject(err)

        repo_match = resp.match(GITHUB_REPO_REGEX)
        return resolve(exists: false) unless repo_match

        resolve(exists: true, name: repo_match[1])
