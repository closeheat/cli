path = require 'path'
serve_static = require 'serve-static'
charge = require 'charge'
util = require 'util'
chalk = require 'chalk'
fs = require 'fs'
Watcher = require './watcher'
homePath = require('home-path')

module.exports =
class Server
  constructor: ->
    @src = process.cwd()
    @dist = "#{homePath()}/.closeheat/tmp/apps/321app-token321/"

  start: (opts = {}) ->
    opts.log = false
    live_reload_host = opts.ip || 'localhost'

    opts.write = content:
      "
      <!-- closeheat development config -->
      <script src='http://#{live_reload_host}:35729/livereload.js'></script>
      "
    opts.cache_control = {'**': 'max-age=0, no-cache, no-store'}

    new Watcher(@src, @dist).run()
    app = charge(path.join(@dist, 'app'), opts)

    port = opts.port || 9000
    @server = app.start(port)
    util.puts(chalk.blue("Server started at http://0.0.0.0:#{port}"))
