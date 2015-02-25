Promise = require 'bluebird'
Git = require 'git-wrapper'
inquirer = require 'inquirer'
_ = require 'lodash'

Initializer = require './initializer'
Authorized = require './authorized'
Urls = require './urls'

Log = require './log'
Color = require './color'

module.exports =
class Deployer
  deploy: ->
    @git = new Git()

    Log.spin('Deploying the app to closeheat.com via Github.')
    @addEverything().then(=>
      Log.stop()
      Log.inner('All files added.')
      @commit('Deploy via CLI').then =>
        Log.inner('Files commited.')
        Log.inner('Pushing to Github.')
        @pushToMainBranch().then (branch)=>
          Log.inner("Pushed to #{branch} branch on Github.")
          @deployLog().then (deployed_name) ->
            url = "http://#{deployed_name}.closeheatapp.com"
            Log.p("App deployed to #{Color.violet(url)}.")
            Log.p('Open it quicker with:')
            Log.code('closeheat open')

    ).catch (err) ->
      Log.error(err)

  addEverything: ->
    new Promise (resolve, reject) =>
      @git.exec 'add', ['.'], (err, resp) ->
        return reject(err) if err

        resolve()

  commit: (msg) ->
    new Promise (resolve, reject) =>
      @git.exec 'commit', m: true, ["'#{msg}'"], (err, resp) ->
        resolve()

  pushToMainBranch: ->
    new Promise (resolve, reject) =>
      @ensureAppAndRepoExist().then =>
        @getMainBranch().then (main_branch) =>
          @push(main_branch).then ->
            resolve(main_branch)

  ensureAppAndRepoExist: ->
    new Promise (resolve, reject) =>
      @repoExist().then (exist) =>
        if exist
          resolve()
        else
          @askToCreateApp().then(resolve)

  askToCreateApp: ->
    new Promise (resolve, reject) =>
      inquirer.prompt({
        message: 'This app is not deployed yet. Would you like create a new closeheat app and deploy via Github?'
        type: 'confirm'
        name: 'create'
      }, (answer) ->
        if answer.create
          new Initializer().init().then(resolve)
        else
          Log.error 'You cannot deploy this app without the closeheat backend and Github setup'
      )

  repoExist: ->
    new Promise (resolve, reject) =>
      @git.exec 'remote', (err, msg) ->
        return reject(err) if err

        origin = msg.match(/origin/)
        resolve(origin)

  getMainBranch: ->
    new Promise (resolve, reject) ->
      resolve('master')

  push: (branch) ->
    new Promise (resolve, reject) =>
      @git.exec 'push', ['origin', branch], (err, msg) ->
        return reject(err) if err

        resolve()

  deployLog: ->
    new Promise (resolve, reject) =>
      @getOriginRepo().then (repo) =>
        @pollAndLogUntilDeployed(repo).then =>
          Log.br()
          resolve(@slug)

  pollAndLogUntilDeployed: (repo) ->
    new Promise (resolve, reject) =>
      @status = 'none'
      Log.br()
      @promiseWhile(
        (=> @status != 'deployed'),
        (=> @requestAndLogStatus(repo))
      ).then(resolve)

  promiseWhile: (condition, action) ->
    new Promise (resolve, reject) ->
      repeat = ->
        if !condition()
          return resolve()
        Promise.cast(action()).then(->
          _.delay(repeat, 1000)).catch(reject)

      process.nextTick repeat

  requestAndLogStatus: (repo) ->
    Authorized.request url: Urls.deployStatus(), repo: repo, method: 'post', json: true, (err, resp) =>
      Log.fromBackendStatus(resp.body.status) if resp.body.status != @status
      @status = resp.body.status
      @slug = resp.body.slug

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  getOriginRepo: ->
    new Promise (resolve, reject) =>
      @git.exec 'remote', ['--verbose'], (err, resp) ->
        return reject(err) if err

        resolve(resp.match(GITHUB_REPO_REGEX)[1])
