request = require 'request'
_ = require 'lodash'
table = require('text-table')

Authorizer = require './authorizer'
Urls = require './urls'
Log = require './log'
Color = require './color'

module.exports =
class Apps
  list: =>
    authorizer = new Authorizer
    params =
      api_token: authorizer.accessToken()

    Log.logo()
    Log.spin 'Getting information about your deployed apps.'
    request url: Urls.appsIndex(), qs: params, method: 'get', (err, resp) =>
      Log.stop()

      if resp.statusCode == 401
        Log.p 'Please login to closeheat.com to check out your app list.'
        return authorizer.login(@list)

      return Log.error(err) if err

      parsed_resp = null
      try
        parsed_resp = JSON.parse(resp.body)
      catch e
        return Log.backendError()

      if parsed_resp.apps.length
        @table(parsed_resp.apps)
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
