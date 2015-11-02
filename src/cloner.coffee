Promise = require 'bluebird'

Git = require './git'
Authorized = require './authorized'
Urls = require './urls'
Log = require './log'
Notifier = require './notifier'

module.exports =
class Cloner
  clone: (slug) ->
    Log.logo()
    Log.spin "Getting website information for #{slug}."

    @getAppData(slug).then((app) =>
      Log.stop()
      Log.br()
      Log.spin "Cloning GitHub repository from #{app.github_repo}."

      @execCloning(app.github_repo, app.default_branch, slug).then =>
        Notifier.notify('app_clone', app.slug)

        Log.stop()
        Log.inner "Cloned the app code to directory '#{slug}'."

        Log.br()
        Log.p 'The quickest way to deploy changes to closeheat.com and GitHub is with:'
        Log.secondaryCode 'closeheat deploy'

        Log.br()
        Log.p 'For more awesome tricks type:'
        Log.secondaryCode 'closeheat help'
    ).catch (err) ->
      Log.error(err)

  getAppData: (slug) ->
    new Promise (resolve, reject) ->
      Authorized.post(Urls.findWebsite(), slug: slug).then (resp) ->
        return Log.error "Website named '#{slug}' does not exist." unless resp.exists

        resolve(resp)

  execCloning: (github_repo, branch, slug) ->
    @git = new Git()

    new Promise (resolve, reject) ->
      new Git().exec 'clone', ["git@github.com:#{github_repo}.git", slug], (err, resp) ->
        return reject(err) if err

        resolve()
