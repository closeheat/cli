fs = require 'fs'
through = require('through2')
path = require 'path'
gulp = require 'gulp'
gutil = require 'gutil'
coffee = require 'gulp-coffee'
acorn = require 'acorn'

module.exports =
class Requirer
  constructor: (@dist) ->

  scan: ->
    console.log 'Scanning'
    console.log path.join(@dist, '**/*.js')
    console.log path.join(@dist, 'node_modules')

    gulp
      .src('/home/domas/Developer/cli-testing/**/*.js')
      .pipe(@scanner())
      .pipe gulp.dest(path.join(@dist, 'node_modules'))

  downloader: (arg) ->
    console.log 'down'
    console.log (arg)

  scanner: (file) ->
    through.obj (file, enc, cb) ->
      console.log "File detected"
      return if (file.isNull())

      console.log file.contents.toString()
      ast = acorn.parse(file.contents.toString())
      walk = require('acorn/util/walk')
      walkall = require('walkall')

      walk.simple(ast, walkall.makeVisitors((node) ->
        return unless node.type == 'CallExpression'
        return unless node.callee.name == 'require'

        module_name = node.arguments[0].value
        return unless module_name.match(/^[a-zA-Z]/)

        console.log module_name
      ), walkall.traversers)

      cb()
