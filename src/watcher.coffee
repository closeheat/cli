util = require 'util'
rimraf = require 'rimraf'
path = require 'path'
tinylr = require 'tiny-lr'
Promise = require 'bluebird'
moment = require 'moment'
_ = require 'lodash'
gulp = require 'gulp'

Builder = require 'closeheat-builder'

Dirs = require './dirs'

Log = require './log'
Color = require './color'

module.exports =
class Watcher
  constructor: (@src, @dist) ->
    @watcher = gulp.watch(path.join(@src, '**/*.*'))

  run: ->
    debouncedBuild = _.debounce(@build, 2500, leading: true)

    @watcher
      .on('error', (err) -> Log.error(err))
      .on('change', debouncedBuild)
      .on('all', debouncedBuild)

  build: (e, file) =>
    new Promise (resolve, reject) =>
      @logFileChanged(file) if file
      @execBuild(resolve, reject)

  execBuild: (resolve, reject) ->
    Log.spin('Building the app.')
    rimraf.sync(@dist)

    new Builder(@src, @dist, Dirs.buildTmp())
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
      Log.inner("#{Color.violet(moment().format('hh:mm:ss'))} | App built.")
    ).catch((err) ->
      Log.error('Could not compile', false)
      Log.innerError(err, false)
      Log.br()
    )

  logFileChanged: (file) ->
    relative = path.relative(@src, file)
    Log.stop()
    Log.br()
    Log.doneLine("#{relative} changed.")
