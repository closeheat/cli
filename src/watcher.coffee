builder = require 'closeheat-builder'
chokidar  = require 'chokidar'
util = require 'util'
chalk = require 'chalk'
rimraf = require 'rimraf'
Requirer = require './requirer'
fs = require 'fs'

module.exports =
class Watcher
  constructor: (@src, @dist) ->
    @watcher = chokidar.watch @src,
      ignoreInitial: true

  run: ->
    @build()

    @watcher
      .on('error', (err) -> util.puts(err))
      .on('all', (e, file) => @build(e, file))

  build: (e, file) ->
    rimraf.sync(@dist)
    builder.build(@src, @dist).then ->
      util.puts("#{chalk.blue('App rebuilt')} - File #{file} #{e}.") if file
      util.puts "Reading #{dist}"
      fs.readdir @dist, (err, files) ->
        console.log(files)
      new Requirer(@dist).scan()
