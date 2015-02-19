path = require 'path'
serve_static = require 'serve-static'
charge = require 'charge'
util = require 'util'
chalk = require 'chalk'
fs = require 'fs'
Watcher = require './watcher'
homePath = require('home-path')

Log = require './log'
Color = require './color'

module.exports =
class Server
  constructor: ->
    @src = process.cwd()
    @dist = "#{homePath()}/.closeheat/tmp/apps/current/"

  start: (opts = {}) ->
    Log.logo()

    opts.log = false
    live_reload_host = opts.ip || 'localhost'

    opts.write = content:
      "
      <!-- closeheat development config -->
      <script src='http://#{live_reload_host}:35729/livereload.js'></script>
      "
    opts.cache_control = {'**': 'max-age=0, no-cache, no-store'}

    watcher = new Watcher(@src, @dist)

    watcher.build().then =>
      app = charge(path.join(@dist, 'app'), opts)

      port = opts.port || 9000
      @server = app.start(port)
      Log.doneLine("Server started at " + Color.violet("http://0.0.0.0:#{port}"))

      watcher.run()
