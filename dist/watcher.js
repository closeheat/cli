var Color, Log, Requirer, Watcher, builder, chalk, chokidar, fs, gulp, moment, path, q, rimraf, tinylr, util;

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

q = require('bluebird');

moment = require('moment');

Log = require('./log');

Color = require('./color');

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
    return new q((function(_this) {
      return function(resolve, reject) {
        var relative;
        if (file) {
          relative = path.relative(_this.src, file);
          Log.inner("" + relative + " changed.");
        }
        Log.spin("Building the app.");
        rimraf.sync(_this.dist_app);
        return builder.build(_this.src, _this.dist_app).then(function() {
          return new Requirer(_this.dist, _this.dist_app).install().then(function() {
            tinylr.changed('/');
            resolve();
            Log.stop();
            Log.br();
            Log.inner("" + (Color.violet(moment().format('hh:mm:ss'))) + " | App built.");
            return Log.br();
          });
        }).fail(function(err) {
          return console.log(err);
        });
      };
    })(this));
  };

  return Watcher;

})();
