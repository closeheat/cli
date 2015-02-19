var Log, Requirer, Watcher, builder, chalk, chokidar, fs, gulp, path, rimraf, tinylr, util;

builder = require('closeheat-builder');

chokidar = require('chokidar');

util = require('util');

chalk = require('chalk');

rimraf = require('rimraf');

Requirer = require('./requirer');

fs = require('fs-extra');

path = require('path');

tinylr = require('tiny-lr');

gulp = require('gulp');

Log = require('./log');

module.exports = Watcher = (function() {
  function Watcher(src, dist) {
    this.src = src;
    this.dist = dist;
    this.dist_app = path.join(this.dist, 'app');
    this.watcher = chokidar.watch(this.src, {
      ignoreInitial: true
    });
  }

  Watcher.prototype.run = function() {
    var port;
    this.build();
    this.watcher.on('error', function(err) {
      return util.puts(err);
    }).on('all', (function(_this) {
      return function(e, file) {
        return _this.build(e, file);
      };
    })(this));
    port = 35729;
    return tinylr().listen(port, function() {});
  };

  Watcher.prototype.build = function(e, file) {
    var relative;
    if (file) {
      relative = path.relative(this.src, file);
      Log.spin("" + relative + " changed. Rebuilding the app.");
    }
    rimraf.sync(this.dist_app);
    return builder.build(this.src, this.dist_app).then((function(_this) {
      return function() {
        if (file) {
          Log.stop();
        }
        return new Requirer(_this.dist, _this.dist_app).scan().then(function() {
          return tinylr.changed('/');
        });
      };
    })(this));
  };

  return Watcher;

})();
