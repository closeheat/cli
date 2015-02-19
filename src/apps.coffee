gulp = require 'gulp'
git = require 'gulp-git'
q = require 'bluebird'
rp = require 'request-promise'
request = require 'request'
_ = require 'lodash'
util = require('util')
Table = require('cli-table')

Authorizer = require './authorizer'
Urls = require './urls'
Log = require './log'

module.exports =
class Apps
  list: ->
    authorizer = new Authorizer
    params =
      api_token: authorizer.accessToken()


    Log.logo()
    Log.spin 'Getting information about your deployed apps.'
    request url: Urls.appsIndex(), qs: params, method: 'get', (err, resp) =>
      Log.spinStop()
      return Log.error(err) if err

      apps = JSON.parse(resp.body).apps

      if apps.length
        @table(apps)
      else
        @noApps()

  table: (apps) ->
    util.puts ''
    util.puts "You have #{apps.length} apps deployed."
    util.puts ''

    apps_list = new Table head: ['Name', 'Clone command']

    _.each apps, (app) ->
      apps_list.push [app.name, "closeheat clone #{app.slug}"]

    util.puts(apps_list.toString())
    util.puts ''
    util.puts ''
    util.puts "Edit any of your apps by cloning it with:"
    util.puts ''
    util.puts "  closeheat clone your-awesome-app"

  noApps: ->
    util.puts "You currently have no apps deployed."
    util.puts "Create an app by typing:"
    util.puts "  closeheat create my-awesome-app"
