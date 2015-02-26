path = require 'path'
charge = require 'charge'
homePath = require('home-path')
tinylr = require 'tiny-lr'

Watcher = require './watcher'
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
      app = charge(@dist, opts)

      port = opts.port || 9000
      @server = app.start(port)

      lr_port = 35729
      tinylr().listen lr_port, ->
        Log.doneLine('Server started at ' + Color.violet("http://localhost:#{port}") + '.')

        if live_reload_host == 'localhost'
          Log.inner "LiveReload up via port #{lr_port}."
        else
          Log.inner "LiveReload up via http://#{live_reload_host}:#{lr_port}."

        watcher.run()
