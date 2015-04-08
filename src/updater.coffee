checkUpdate = require 'check-update'
Promise = require 'bluebird'

Config = require './config'
Log = require './log'
Color = require './color'

module.exports =
class Updater
  update: ->
    @exec().then =>
      @saveLastCheckTime()

  exec: ->
    new Promise (resolve, reject) =>
      if @longTimeNoUpdate()
        @checkForUpdate().then (update_data) =>
          @askForUpdate(update_data.version) if update_data.exists
          resolve()
      else
        resolve()

  longTimeNoUpdate: ->
    last_update_check = Config.fileContents().last_update_check || Date.now()

    Date.now() - last_update_check > 1 * 24 * 60 * 60

  saveLastCheckTime: ->
    Config.update('last_update_check', Date.now())

  askForUpdate: (version) ->
    Log.p "A new version (#{version}) of closeheat is available. Run #{Color.violet('npm update closeheat -g')} to update."
    Log.br()

  checkForUpdate: ->
    new Promise (resolve, reject) =>
      checkUpdate
        packageName: 'closeheat',
        (err, latest) ->
          if err
            reject()
          else
            resolve(exists: Config.version() < latest, version: latest)
