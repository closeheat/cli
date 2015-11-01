Promise = require 'bluebird'

Git = require './git'
Authorized = require './authorized'
Urls = require './urls'
Log = require './log'
Notifier = require './notifier'

module.exports =
class Cloner
  clone: (app_name) ->
    Log.logo()
    Log.spin "Getting website information for #{app_name}."

    @getAppData(app_name).then((app) =>
      Log.stop()
      Log.br()
      Log.spin "Cloning GitHub repository from #{app.github_repo}."

      @execCloning(app.github_repo, app.default_branch, app_name).then =>
        Notifier.notify('app_clone', app.slug)

        Log.stop()
        Log.inner "Cloned the app code to directory '#{app_name}'."

        Log.br()
        Log.p 'The quickest way to deploy changes to closeheat.com and GitHub is with:'
        Log.secondaryCode 'closeheat deploy'

        Log.br()
        Log.p 'For more awesome tricks type:'
        Log.secondaryCode 'closeheat help'
    ).catch (err) ->
      Log.error(err)

  getAppData: (app_name) ->
    new Promise (resolve, reject) ->
      Authorized.get(Urls.appData(app_name)).then (resp) ->
        return Log.error "Website named '#{app_name}' does not exist." if !resp.app

        resolve(resp.app)

  execCloning: (github_repo, branch, app_name) ->
    @git = new Git()

    new Promise (resolve, reject) ->
      new Git().exec 'clone', ["git@github.com:#{github_repo}.git", app_name], (err, resp) ->
        return reject(err) if err

        resolve()
