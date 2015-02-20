fs = require 'fs'
Promise = require 'bluebird'
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
acorn = require 'acorn'

Log = require './log'
Color = require './color'

module.exports =
class RequireScanner
  constructor: (@dist_app) ->
    @modules = []

  register: (module) ->
    @modules.push(module)

  getRequires: ->
    new Promise (resolve, reject) =>
      gulp
        .src(path.join(@dist_app, '**/*.js'))
        .pipe(@scan(resolve, reject).on('error', reject))

  finish: (resolve, _done) =>
    resolve(@modules)

  scan: (resolve, reject) ->
    through.obj((file, enc, cb) =>
      try
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

          @register(module_name)
        ), walkall.traversers)

        cb()

      catch e
        reject(e.stack)
    , _.partial(@finish, resolve))
