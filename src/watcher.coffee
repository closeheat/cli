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
injectReload = require 'gulp-inject-reload'

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
    rimraf.sync(@dist_app)

    builder.build(@src, @dist_app).then =>
      util.puts("#{chalk.blue('App rebuilt')} - File #{file} #{e}.") if file
      tinylr.changed('/')

      new Requirer(@dist, @dist_app).scan()
