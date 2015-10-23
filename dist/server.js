var Color, Log, Notifier, Server, Watcher, charge, homePath, path, tinylr;

path = require('path');

charge = require('charge');

homePath = require('home-path');

tinylr = require('tiny-lr');

Watcher = require('./watcher');

Log = require('./log');

Color = require('./color');

Notifier = require('./notifier');

module.exports = Server = (function() {
  function Server() {
    this.src = process.cwd();
    this.dist = (homePath()) + "/.closeheat/tmp/apps/current/";
  }

  Server.prototype.start = function(opts) {
    var live_reload_host, watcher;
    if (opts == null) {
      opts = {};
    }
    Notifier.notify('server_start');
    Log.logo();
    opts.log = false;
    live_reload_host = opts.ip || 'localhost';
    opts.write = {
      content: "<!-- closeheat development config --> <script src='http://" + live_reload_host + ":35729/livereload.js'></script>"
    };
    opts.cache_control = {
      '**': 'max-age=0, no-cache, no-store'
    };
    watcher = new Watcher(this.src, this.dist);
    return watcher.build().then((function(_this) {
      return function() {
        var app, lr_port, port;
        app = charge(_this.dist, opts);
        port = opts.port || 9000;
        _this.server = app.start(port);
        lr_port = 35729;
        return tinylr().listen(lr_port, function() {
          Log.doneLine('Server started at ' + Color.violet("http://localhost:" + port) + '.');
          if (live_reload_host === 'localhost') {
            Log.inner("LiveReload up via port " + lr_port + ".");
          } else {
            Log.inner("LiveReload up via http://" + live_reload_host + ":" + lr_port + ".");
          }
          return watcher.run();
        });
      };
    })(this));
  };

  return Server;

})();
