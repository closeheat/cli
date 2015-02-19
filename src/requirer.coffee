fs = require 'fs'
through = require('through2')
path = require 'path'
gulp = require 'gulp'
gutil = require 'gutil'
util = require 'util'
coffee = require 'gulp-coffee'
_ = require 'lodash'
callback = require 'gulp-callback'
npmi = require('npmi')
htmlparser = require("htmlparser2")

Log = require './log'
Color = require './color'

NpmDownloader = require './npm_downloader'
Bundler = require './bundler'
RequireScanner = require './require_scanner'

module.exports =
class Requirer
  constructor: (@dist, @dist_app) ->
    @bundler = new Bundler(@dist_app)
    @require_scanner = new RequireScanner(@dist_app)

  install: ->
    @require_scanner.getRequires().then (modules) =>
      new NpmDownloader(@dist, modules).downloadAll().then =>
        console.log "bund"
        @bundler.bundle()
