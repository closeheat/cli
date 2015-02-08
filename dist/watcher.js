var Requirer, Watcher, builder, chalk, chokidar, fs, rimraf, util;

builder = require('closeheat-builder');

chokidar = require('chokidar');

util = require('util');

chalk = require('chalk');

rimraf = require('rimraf');

Requirer = require('./requirer');

fs = require('fs');

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
    return builder.build(this.src, this.dist).then(function() {
      if (file) {
        util.puts("" + (chalk.blue('App rebuilt')) + " - File " + file + " " + e + ".");
      }
      util.puts("Reading " + dist);
      fs.readdir(this.dist, function(err, files) {
        return console.log(files);
      });
      return new Requirer(this.dist).scan();
    });
  };

  return Watcher;

})();
