var Server, Watcher, chalk, charge, fs, homePath, path, serve_static, util;

path = require('path');

serve_static = require('serve-static');

charge = require('charge');

util = require('util');

chalk = require('chalk');

fs = require('fs');

Watcher = require('./watcher');

homePath = require('home-path');

module.exports = Server = (function() {
  function Server() {
    this.src = process.cwd();
    this.dist = "" + (homePath()) + "/.closeheat/tmp/apps/321app-token321/";
  }

  Server.prototype.start = function(port, cb) {
    var app, opts;
    opts = {};
    opts.log = false;
    opts.write = {
      content: "<!-- closeheat development config --> <script>var closeheat = {};</script> <script>var closeheat.livereload = true;</script> <script src='bundle.js'></script>"
    };
    opts.cache_control = {
      '**': 'max-age=0, no-cache, no-store'
    };
    new Watcher(this.src, this.dist).run();
    app = charge(path.join(this.dist, 'app'), opts);
    port = 9000;
    this.server = app.start(port);
    return util.puts(chalk.blue("Server started at http://0.0.0.0:" + port));
  };

  return Server;

})();
