Promise = require 'bluebird'
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
    Log.spin 'Getting information about your websites.'

    new Promise (resolve, reject) =>
      Authorized.get(Urls.appsIndex()).then (resp) =>
        Log.stop()

        if resp.apps.length
          @table(resp.apps)
        else
          @noApps()

        resolve()

  table: (apps) ->
    Log.inner "You have #{apps.length} websites."

    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]]
    _.each apps, (app) ->
      list.push ['', Color.violet(app.name), Color.bare("closeheat clone #{app.slug}")]

    Log.br()
    Log.line(table(list))
    Log.br()
    Log.line 'Edit any of your websites by cloning it with:'
    Log.code('closeheat clone awesome-website')

  noApps: ->
    Log.inner 'You have no websites.'
    Log.br()
    Log.line 'Publish this folder as a website by typing:'
    Log.code('closeheat deploy your-website-name')
