var Watcher, builder, chalk, chokidar, rimraf, util;

builder = require('closeheat-builder');

chokidar = require('chokidar');

util = require('util');

chalk = require('chalk');

rimraf = require('rimraf');

module.exports = Watcher = (function() {
  function Watcher(src, dist) {
    this.src = src;
    this.dist = dist;
    this.watcher = chokidar.watch(this.src, {
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
    rimraf.sync(this.dist);
    builder.build(this.src, this.dist);
    if (file) {
      return util.puts("" + (chalk.blue('App rebuilt')) + " - File " + file + " " + e + ".");
    }
  };

  return Watcher;

})();
