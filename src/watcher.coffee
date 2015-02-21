chokidar  = require 'chokidar'
util = require 'util'
rimraf = require 'rimraf'
path = require 'path'
tinylr = require 'tiny-lr'
Promise = require 'bluebird'
moment = require 'moment'

Builder = require 'closeheat-builder'

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
        Log.stop()
        Log.inner("#{relative} changed.")

      Log.spin('Building the app.')
      rimraf.sync(@dist_app)

      new Builder(@src, @dist)
        .on('module-detected', (module) ->
          Log.spin("New require detected. Installing #{Color.orange(module)}.")
        )
        .on('module-installed', (module) ->
          Log.stop()
          Log.inner "#{Color.orange(module)} installed."
        )
        .build().then(->
          tinylr.changed('/')
          resolve()
          Log.stop()
          Log.br()
          Log.inner("#{Color.violet(moment().format('hh:mm:ss'))} | App built.")
          Log.br()

      ).catch (err) =>
        Log.error('Could not compile', false)
        Log.innerError(err, false)
        Log.br()
        @run()
