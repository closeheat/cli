NpmDownloader = require './npm_downloader'
Bundler = require './bundler'
RequireScanner = require './require_scanner'

module.exports =
class Requirer
  constructor: (@dist, @dist_app) ->
    @bundler = new Bundler(@dist_app)
    @require_scanner = new RequireScanner(@dist_app)

  on: (event_name, cb) ->
    @events ||= {}
    @events[event_name] = cb
    @

  emit: (event_name, data) ->
    @events ||= {}
    @events.all?(event_name, data)

    @events[event_name]?(data)
    @

  handleAllEvents: (event_name, data) =>
    @emit(event_name, data)

  install: =>
    @require_scanner.getRequires().then (modules) =>
      new NpmDownloader(@dist, modules).on('all', @handleAllEvents).downloadAll().then =>
        @bundler.bundle()
