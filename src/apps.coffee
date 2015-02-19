gulp = require 'gulp'
git = require 'gulp-git'
q = require 'bluebird'
rp = require 'request-promise'
request = require 'request'
_ = require 'lodash'
util = require('util')
# Table = require('cli-table')
table = require('text-table')
chalk = require 'chalk'

Authorizer = require './authorizer'
Urls = require './urls'
Log = require './log'
Color = require './color'

module.exports =
class Apps
  list: ->
    authorizer = new Authorizer
    params =
      api_token: authorizer.accessToken()

    Log.logo()
    Log.spin 'Getting information about your deployed apps.'
    request url: Urls.appsIndex(), qs: params, method: 'get', (err, resp) =>
      Log.stop()
      return Log.error(err) if err

      try
        apps = JSON.parse(resp.body).apps
      catch e
        return Log.error('Backend responded with an error.')

      if apps.length
        @table(apps)
      else
        @noApps()

  table: (apps) ->
    Log.inner "You have #{apps.length} apps deployed."

    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]]
    _.each apps, (app) ->
      list.push ['', Color.violet(app.name), Color.bare("closeheat clone #{app.slug}")]

    Log.br()
    Log.line(table(list))
    Log.br()
    Log.line "Edit any of your apps by cloning it with:"
    Log.code("closeheat clone your-awesome-app")

  noApps: ->
    Log.inner "You have no apps deployed."
    Log.br()
    Log.line "Create an app by typing:"
    Log.code("closeheat create your-awesome-app")
