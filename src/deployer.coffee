Promise = require 'bluebird'
Git = require 'git-wrapper'

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
        return reject(err) if err

        resolve()

  pushToMainBranch: ->
    new Promise (resolve, reject) =>
      @getMainBranch().then (main_branch) =>
        @push(main_branch).then ->
          resolve(main_branch)

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
      Log.br()
      Log.backend('Downloading the Github repo.')
      Log.backend('Building app.')
      Log.backend('App is live.')
      Log.br()

      resolve()
