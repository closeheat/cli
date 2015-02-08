var Requirer, Watcher, builder, chalk, chokidar, fs, path, rimraf, util;

builder = require('closeheat-builder');

chokidar = require('chokidar');

util = require('util');

chalk = require('chalk');

rimraf = require('rimraf');

Requirer = require('./requirer');

fs = require('fs');

path = require('path');

module.exports = Watcher = (function() {
  function Watcher(src, dist) {
    this.src = src;
    this.dist = dist;
    this.src_app = path.join(this.src, 'app');
    this.dist_app = path.join(this.dist, 'app');
    this.watcher = chokidar.watch(this.src_app, {
      ignoreInitial: true
    });
  }

  Watcher.prototype.run = function() {
    this.build();
    return this.watcher.on('error', function(err) {
      return util.puts(err);
    }).on('all', (function(_this) {
      return function(e, file) {
        return _this.build(e, file);
      };
    })(this));
  };

  Watcher.prototype.build = function(e, file) {
    rimraf.sync(this.dist_app);
    return builder.build(this.src_app, this.dist_app).then((function(_this) {
      return function() {
        if (file) {
          util.puts("" + (chalk.blue('App rebuilt')) + " - File " + file + " " + e + ".");
        }
        return new Requirer(_this.dist, _this.dist_app).scan();
      };
    })(this));
  };

  return Watcher;

})();
