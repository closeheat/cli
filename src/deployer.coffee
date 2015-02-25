Promise = require 'bluebird'
Git = require 'git-wrapper'
inquirer = require 'inquirer'

Initializer = require './initializer'

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
          @deployLog().then ->
            Log.p("App deployed to #{Color.violet('http://blablabla.closeheatapp.com')}.")
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
    new Promise (resolve, reject) ->
      # Will probably do Authorized.request
      Log.br()
      Log.backend('Downloading the Github repo.')
      Log.backend('Building app.')
      Log.backend('App is live.')
      Log.br()

      resolve()
