builder = require 'closeheat-builder'
chokidar  = require 'chokidar'
util = require 'util'
chalk = require 'chalk'
rimraf = require 'rimraf'
Requirer = require './requirer'
fs = require('fs-extra')
path = require 'path'
tinylr = require 'tiny-lr'
gulp = require 'gulp'

Log = require './log'

module.exports =
class Watcher
  constructor: (@src, @dist) ->
    @dist_app = path.join(@dist, 'app')

    @watcher = chokidar.watch @src,
      ignoreInitial: true

  run: ->
    @build()

    @watcher
      .on('error', (err) -> util.puts(err))
      .on('all', (e, file) => @build(e, file))

    port = 35729
    tinylr().listen port, ->

  build: (e, file) ->
    if file
      relative = path.relative(@src, file)
      Log.spin("#{relative} changed. Rebuilding the app.")

    rimraf.sync(@dist_app)

    builder.build(@src, @dist_app).then =>
      Log.stop() if file

      new Requirer(@dist, @dist_app).scan().then ->
        tinylr.changed('/')
