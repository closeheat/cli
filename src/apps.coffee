gulp = require 'gulp'
git = require 'gulp-git'
q = require 'bluebird'
rp = require 'request-promise'
request = require 'request'
_ = require 'lodash'
util = require('util')
Table = require('cli-table')

Authorizer = require './authorizer'

module.exports =
class Apps
  APPS_INDEX = 'http://staging.closeheat.com/api/apps'
  # APPS_INDEX = 'http://10.30.0.1:4000/api/apps'

  showList: ->
    authorizer = new Authorizer
    params =
      api_token: authorizer.accessToken()

    util.puts 'Getting Your Application Info...'
    request url: APPS_INDEX, qs: params, method: 'get', (err, resp) =>
      throw Error 'Error happened' if err

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
