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
    new q (resolve, reject) =>
      gulp
        .src(path.join(@dist_app, '**/*.js'))
        .pipe(@minFilter())
        .pipe(@exec(resolve, reject).on('error', gutil.log))

  minFilter: ->
    gulpFilter (file) ->
      !/.min./.test(file.path)

  exec: (resolve, reject) ->
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

    , resolve)
