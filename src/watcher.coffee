builder = require 'closeheat-builder'
chokidar  = require 'chokidar'
util = require 'util'
rimraf = require 'rimraf'
path = require 'path'
tinylr = require 'tiny-lr'
Promise = require 'bluebird'
moment = require 'moment'

Requirer = require './requirer'
Log = require './log'
Color = require './color'

module.exports =
class Watcher
  constructor: (@src, @dist) ->
    @dist_app = path.join(@dist, 'app')

    @watcher = chokidar.watch @src,
      ignoreInitial: true

  run: ->
    @watcher
      .on('error', (err) -> Log.error(err))
      .on('all', (e, file) => @build(e, file))

  build: (e, file) ->
    new Promise (resolve, reject) =>
      if file
        relative = path.relative(@src, file)
        Log.inner("#{relative} changed.")

      Log.spin("Building the app.")
      rimraf.sync(@dist_app)

      builder.build(@src, @dist_app).then(=>
        new Requirer(@dist, @dist_app).install().then ->
          tinylr.changed('/')
          resolve()
          Log.stop()
          Log.br()
          Log.inner("#{Color.violet(moment().format('hh:mm:ss'))} | App built.")
          Log.br()

      ).catch (err) ->
        Log.error('Could not compile')
        Log.error(err)
