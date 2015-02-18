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

module.exports =
class Requirer
  constructor: (@dist, @dist_app) ->
    @modules = []

  scan: ->
    console.log path.join(@dist_app, '**/*.js')
    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(@scanner().on('error', gutil.log))
      .on 'end', -> console.log 'scanned'

  registerModule: (module_name) ->
    @modules.push(module_name)

  downloadModules: =>
    package_file = {
      name: 'closeheat-app'
      version: '1.0.0'
      dependencies: {},
      path: '.',
    }

    total = @modulesToDownload().length
    @continueBundling() if total == 0

    count = 0
    _.each @modulesToDownload(), (module) =>
      npmi name: module, path: @dist, (err, result) =>
        count += 1

        if result
          package_file.dependencies[module] = ''
          util.puts("#{module} installed")

        @continueBundling() if count == total


    fs.writeFileSync(path.join(@dist, 'package.json'), JSON.stringify(package_file))

  continueBundling: ->
    min_filter = gulpFilter (file) ->
      !/.min./.test(file.path)

    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(min_filter)
      .pipe(@bundler().on('error', gutil.log))
      .on 'end', -> console.log 'scanned'

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
    console.log 'Finighe bundle'

  modulesToDownload: ->
    _.uniq(@modules)

  scanner: ->
    through.obj((file, enc, cb) =>
      console.log file.path
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

        @registerModule(module_name)
      ), walkall.traversers)
      console.log file.path

      cb()
    , @downloadModules)
