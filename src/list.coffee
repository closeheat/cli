Promise = require 'bluebird'
request = require 'request'
_ = require 'lodash'
table = require('text-table')

Authorized = require './authorized'
Urls = require './urls'
Log = require './log'
Color = require './color'

module.exports =
class List
  show: =>
    Log.logo()
    Log.spin 'Getting information about your deployed apps.'

    new Promise (resolve, reject) =>
      Authorized.request url: Urls.appsIndex(), method: 'get', (err, resp) =>
        Log.stop()

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

        resolve()

  table: (apps) ->
    Log.inner "You have #{apps.length} apps deployed."

    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]]
    _.each apps, (app) ->
      list.push ['', Color.violet(app.name), Color.bare("closeheat clone #{app.slug}")]

    Log.br()
    Log.line(table(list))
    Log.br()
    Log.line 'Edit any of your apps by cloning it with:'
    Log.code('closeheat clone your-awesome-app')

  noApps: ->
    Log.inner 'You have no apps deployed.'
    Log.br()
    Log.line 'Deploy this app by typing:'
    Log.code('closeheat deploy your-app-name')
