Promise = require 'bluebird'
_ = require 'lodash'
Git = require 'git-wrapper'

Log = require './log'
Authorized = require './authorized'
Urls = require './urls'
BackendLogger = require './backend_logger'
Website = require './website'

module.exports =
class DeployLog
  constructor: ->
    @backend_logger = new BackendLogger()
    @git = new Git()

  fromCurrentCommit: ->
    new Promise (resolve, reject) =>
      @pollAndLogUntilDeployed().then =>
        Log.br()
        resolve(@slug)

  pollAndLogUntilDeployed: ->
    new Promise (resolve, reject) =>
      @status = 'none'
      Log.br()

      @promiseWhile(
        (=> !_.contains(['success', 'failed', null], @status)),
        (=> @requestAndLogStatus())
      ).then(resolve)

  requestAndLogStatus: =>
    Website.get().then (website) =>
      @getSha().then (sha) =>
        Authorized.post(Urls.buildForCLI(website.slug), commit_sha: sha).then (resp) =>
          build = resp.build
          @backend_logger.log(build)
          @status = build.status

  getSha: ->
    new Promise (resolve, reject) =>
      @git.exec 'rev-parse', ['HEAD'], (err, resp) ->
        return reject(err) if err

        resolve(resp.trim())

  promiseWhile: (condition, action) ->
    new Promise (resolve, reject) ->
      repeat = ->
        if !condition()
          return resolve()
        Promise.cast(action()).then(->
          _.delay(repeat, 1000)).catch(reject)

      process.nextTick repeat
