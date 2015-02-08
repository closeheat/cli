path = require 'path'
serve_static = require 'serve-static'
charge = require 'charge'
util = require('util')
chalk = require('chalk')

module.exports =
class Server
  constructor: ->

  start: (port, cb) ->
    opts = {}
    opts.log = false

    opts.write = content:
      "
      <!-- closeheat development config -->
      <script>var closeheat = {};</script>
      <script>var closeheat.livereload = true;</script>
      "
    opts.cache_control = {'**': 'max-age=0, no-cache, no-store'}

    app = charge('app', opts)

    @server = app.start(4000)
    util.puts("Server started at #{chalk.blue('http://0.0.0.0:4000')}")
