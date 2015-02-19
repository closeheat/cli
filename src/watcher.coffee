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
q = require 'bluebird'
moment = require('moment')

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
      .on('error', (err) -> util.puts(err))
      .on('all', (e, file) => @build(e, file))

    port = 35729
    tinylr().listen port, ->

  build: (e, file) ->
    new q (resolve, reject) =>
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

      ).fail (err) ->
        console.log err
