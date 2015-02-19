gulp = require 'gulp'
git = require 'gulp-git'
Q = require 'q'
q = require('bluebird')
callback = require 'gulp-callback'
gutil = require 'gulp-util'

request = require 'request'
util = require('util')
Authorizer = require './authorizer'
Urls = require './urls'
Log = require './log'

module.exports =
class Cloner
  clone: (app_name) ->
    Log.logo()
    Log.spin "Getting application data for #{app_name}."

    @getAppData(app_name).then (app) =>
      Log.stop()
      Log.spin "Cloning Github repository at #{app.github_repo}."

      @execCloning(app.github_repo, app.default_branch, app_name).then =>
        Log.stop()
        Log.inner "Cloned the app code to directory '#{app_name}'."

        Log.br()
        Log.line 'Run the server by typing:'
        Log.code [
          "cd #{app_name}"
          'closeheat'
        ]

        Log.br()
        Log.p 'The quickest way to deploy changes to closeheat.com and Github is with:'
        Log.secondaryCode 'closeheat deploy'

        Log.br()
        Log.p 'For more awesome tricks type:'
        Log.secondaryCode 'closeheat help'

  getAppData: (app_name) ->
    authorizer = new Authorizer
    params =
      api_token: authorizer.accessToken()

    new q (resolve, reject) ->
      request url: Urls.appData(app_name), qs: params, method: 'get', (err, resp) ->
        app = JSON.parse(resp.body).app

        resolve(app)

  execCloning: (github_repo, branch, app_name) ->
    new q (resolve, reject) ->
      git.clone "git@github.com:#{github_repo}.git", args: "#{app_name}", quiet: true, (err) ->
        throw err if err

        resolve()

  showDeployLog: ->
    console.log('Deploying to closeheat.')
    console.log('............ SOME LOG HERE ..........')
    console.log('Should be done.')
