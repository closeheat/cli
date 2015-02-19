fs = require 'fs'
q = require 'bluebird'
_ = require 'lodash'
path = require 'path'
gulpFilter = require('gulp-filter')
through = require('through2')
browserify = require 'browserify'
source = require('vinyl-source-stream')
buffer = require('vinyl-buffer')
sourcemaps = require('gulp-sourcemaps')
gulp = require 'gulp'
gutil = require 'gutil'

Log = require './log'
Color = require './color'

module.exports =
class Bundler
  constructor: (@dist_app) ->

  bundle: ->
    console.log 'bndling'
    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(@minFilter())
      .pipe(@exec().on('error', gutil.log))
      .on 'end', -> console.log 'scanned'

  minFilter: ->
    gulpFilter (file) ->
      !/.min./.test(file.path)

  finishedBundling: ->
    console.log 'Finighe bundle'

  exec: ->
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
