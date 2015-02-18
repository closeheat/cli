var Requirer, Watcher, builder, chalk, chokidar, fs, gulp, path, rimraf, tinylr, util;

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
    rimraf.sync(this.dist_app);
    return builder.build(this.src, this.dist_app).then((function(_this) {
      return function() {
        if (file) {
          util.puts("" + (chalk.blue('App rebuilt')) + " - File " + file + " " + e + ".");
        }
        tinylr.changed('/');
        return new Requirer(_this.dist, _this.dist_app).scan();
      };
    })(this));
  };

  return Watcher;

})();
