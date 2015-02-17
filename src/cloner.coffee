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

module.exports =
class Cloner
  clone: (app_name) ->
    util.puts "Getting application data for #{app_name}..."

    @getAppData(app_name).then (app) =>
      util.puts "Cloning the repository..."

      @execCloning(app.github_repo, app.default_branch, app_name).then =>
        util.puts "Cloned the app code to #{app_name} directory."
        util.puts '------------------------'

        util.puts ''
        util.puts "Run the server by typing:"
        util.puts "  cd #{app_name}"
        util.puts "  closeheat"

        util.puts ''
        util.puts "The simplest way to deploy changes to closeheat.com is with:"
        util.puts "  closeheat deploy"

        util.puts ''
        util.puts "For more awesome tricks type:"
        util.puts "  closeheat help"

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
      git.clone "https://github.com/#{github_repo}", args: app_name, (err) ->
        throw err if err

        resolve()

  showDeployLog: ->
    console.log('Deploying to closeheat.')
    console.log('............ SOME LOG HERE ..........')
    console.log('Should be done.')
