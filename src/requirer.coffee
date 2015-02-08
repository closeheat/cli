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

module.exports =
class Requirer
  constructor: (@dist, @dist_app) ->
    @modules = []

  scan: ->
    gulp
      .src(path.join(@dist_app, '**/*.js'))
      .pipe(@scanner().on('error', gutil.log))

  downloader: (arg) ->
    console.log 'down'
    console.log (arg)

  registerModule: (module_name) ->
    @modules.push(module_name)

  downloadModules: =>
    package_file = {
      name: 'closeheat-app'
      version: '1.0.0'
      dependencies: {},
      path: '.',
    }

    _.each _.uniq(@modules), (module) =>
      package_file.dependencies[module] = ''

      npmi name: module, path: @dist, (err, result) ->
        util.puts("#{module} installed") if result

    fs.writeFileSync(path.join(@dist, 'package.json'), JSON.stringify(package_file))

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

        @registerModule(module_name)
      ), walkall.traversers)

      cb()
    , @downloadModules)
