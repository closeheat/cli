builder = require 'closeheat-builder'
chokidar  = require 'chokidar'
util = require 'util'
chalk = require 'chalk'
rimraf = require 'rimraf'
Requirer = require './requirer'
fs = require 'fs'
path = require 'path'

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

  build: (e, file) ->
    rimraf.sync(@dist_app)

    builder.build(@src, @dist_app).then =>
      util.puts("#{chalk.blue('App rebuilt')} - File #{file} #{e}.") if file

      new Requirer(@dist, @dist_app).scan()
