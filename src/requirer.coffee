fs = require 'fs'
through = require('through2')
path = require 'path'
gulp = require 'gulp'
gutil = require 'gutil'
util = require 'util'
coffee = require 'gulp-coffee'
acorn = require 'acorn'
_ = require 'lodash'
callback = require 'gulp-callback'
npmi = require('npmi')
htmlparser = require("htmlparser2")
gulpFilter = require('gulp-filter')

browserify = require 'browserify'
source = require('vinyl-source-stream')
buffer = require('vinyl-buffer')
sourcemaps = require('gulp-sourcemaps')

Log = require './log'
Color = require './color'

NpmDownloader = require './npm_downloader'

module.exports =
class Requirer
  constructor: (@dist, @dist_app) ->
    @npm_downloader = new NpmDownloader(@dist)

  scan: ->
    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(@scanner().on('error', gutil.log))
      .on('end', -> console.log 'scanned')

  bundle: =>
    console.log 'con'
    min_filter = gulpFilter (file) ->
      !/.min./.test(file.path)

    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(min_filter)
      .pipe(@bundler().on('error', gutil.log))
      .on 'end', -> console.log 'scanned'

    'c'

  bundler: ->
    through.obj((file, enc, cb) =>
      if file.isNull()
        cb(null, file)
        return

      relative = path.relative(@dist_app, file.path)

      bundler = browserify {
        entries: [file.path]
        debug: true
        standalone: 'CloseheatStandaloneModule'
      }

      bundler
        .bundle()
        .pipe(source(relative))
        .pipe(buffer())
        .pipe(sourcemaps.init(loadMaps: true))
        .pipe(sourcemaps.write('./'))
        .pipe(gulp.dest(@dist_app))
        .on 'end', cb

    , @finishedBundling)

  finishedBundling: ->
    # console.log 'Finighe bundle'

  scanner: ->
    through.obj((file, enc, cb) =>
      if (file.isNull())
        cb(null, file)
        return

      ast = acorn.parse(file.contents.toString())
      walk = require('acorn/util/walk')
      walkall = require('walkall')

      walk.simple(ast, walkall.makeVisitors((node) =>
        return unless node.type == 'CallExpression'
        return unless node.callee.name == 'require'

        module_name = node.arguments[0].value
        return unless module_name.match(/^[a-zA-Z]/)

        @npm_downloader.register(module_name)
      ), walkall.traversers)

      cb()
    , _.partial(@npm_downloader.downloadAll, @bundle))
