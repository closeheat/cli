Promise = require 'bluebird'
_ = require 'lodash'
Git = require 'git-wrapper'

module.exports =
class GitRepository
  @ensure: (opts) =>
    @exists().then (resp) =>
      return _.assign(opts, repository: true) if resp.exists

      @init().then ->
        _.assign(opts, repository: true)

  @init: (url) ->
    new Promise (resolve, reject) =>
      new Git().exec 'init', (err, resp) ->
        return reject(err) if err

        resolve(resp)

  @exists: ->
    new Promise (resolve, reject) =>
      new Git().exec 'remote', ['--verbose'], (err, resp) ->
        if err
          if err.message.match(/Not a git repository/)
            return resolve(exists: false)
          else
            return resolve(exists: true)
        else
          resolve(exists: true)
