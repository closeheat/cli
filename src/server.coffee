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
    @dist = "#{homePath()}/.closeheat/tmp/321app-token321/"

  start: (port, cb) ->
    opts = {}
    opts.log = false

    opts.write = content:
      "
      <!-- closeheat development config -->
      <script>var closeheat = {};</script>
      <script>var closeheat.livereload = true;</script>
      <script src='bundle.js'></script>
      "
    opts.cache_control = {'**': 'max-age=0, no-cache, no-store'}

    new Watcher(@src, @dist).run()
    app = charge(path.join(@dist, 'app'), opts)

    @server = app.start(4000)
    util.puts("Server started at #{chalk.blue('http://0.0.0.0:4000')}")
