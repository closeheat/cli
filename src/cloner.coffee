Promise = require 'bluebird'
Git = require 'git-wrapper'

Authorized = require './authorized'
Urls = require './urls'
Log = require './log'

module.exports =
class Cloner
  clone: (app_name) ->
    Log.logo()
    Log.spin "Getting application data for #{app_name}."

    @getAppData(app_name).then((app) =>
      Log.stop()
      Log.br()
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
    ).catch (err) ->
      Log.error(err)

  getAppData: (app_name) ->
    new Promise (resolve, reject) ->
      Authorized.request url: Urls.appData(app_name), method: 'get', (err, resp) ->
        return reject(err) if err

        try
          app = JSON.parse(resp.body).app
        catch e
          return reject("App named '#{app_name}' does not exist or the server is down.")

        resolve(app)

  execCloning: (github_repo, branch, app_name) ->
    @git = new Git()

    new Promise (resolve, reject) ->
      new Git().exec 'clone', ["git@github.com:#{github_repo}.git", app_name], (err, resp) ->
        return reject(err) if err

        resolve()
