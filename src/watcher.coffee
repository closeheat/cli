builder = require 'closeheat-builder'
chokidar  = require 'chokidar'
util = require 'util'
chalk = require 'chalk'
rimraf = require 'rimraf'

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
    builder.build(@src, @dist)
    util.puts("#{chalk.blue('App rebuilt')} - File #{file} #{e}.") if file
