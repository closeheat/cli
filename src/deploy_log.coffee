Promise = require 'bluebird'
_ = require 'lodash'
Git = require 'git-wrapper'

Log = require './log'
Authorized = require './authorized'
Urls = require './urls'
BackendLogger = require './backend_logger'

module.exports =
class DeployLog
  constructor: ->
    Deployer = require './deployer'
    @deployer = new Deployer()
    @backend_logger = new BackendLogger()
    @git = new Git()

  fromCurrentCommit: ->
    new Promise (resolve, reject) =>
      @deployer.getOriginRepo().then (repo) =>
        @pollAndLogUntilDeployed(repo).then =>
          Log.br()
          resolve(@slug)

  pollAndLogUntilDeployed: (repo) ->
    new Promise (resolve, reject) =>
      @status = 'none'
      Log.br()
      @promiseWhile(
        (=> @status != 'success'),
        (=> @requestAndLogStatus(repo))
      ).then(resolve)

  requestAndLogStatus: (repo) =>
    @getSha().then (sha) =>
      @deployer.getSlug(repo).then (slug) =>
        @slug = slug

        Authorized.request url: Urls.buildForCLI(slug), qs: { commit_sha: sha }, method: 'get', json: true, (err, resp) =>
          if resp.statusCode == 404
            Log.error resp.body.message
          else if resp.statusCode == 200
            build = resp.body.build
            @backend_logger.log(build)
            @status = build.status
          else
            Log.error "Unknown backend error. We're fixing this already."

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
