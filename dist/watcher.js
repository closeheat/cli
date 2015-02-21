var Builder, Color, Log, Promise, Watcher, chokidar, moment, path, rimraf, tinylr, util;

chokidar = require('chokidar');

util = require('util');

rimraf = require('rimraf');

path = require('path');

tinylr = require('tiny-lr');

Promise = require('bluebird');

moment = require('moment');

Builder = require('closeheat-builder');

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
    return this.watcher.on('error', function(err) {
      return Log.error(err);
    }).on('all', (function(_this) {
      return function(e, file) {
        return _this.build(e, file);
      };
    })(this));
  };

  Watcher.prototype.build = function(e, file) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var relative;
        if (file) {
          relative = path.relative(_this.src, file);
          Log.stop();
          Log.inner("" + relative + " changed.");
        }
        Log.spin('Building the app.');
        rimraf.sync(_this.dist_app);
        return new Builder(_this.src, _this.dist).on('module-detected', function(module) {
          return Log.spin("New require detected. Installing " + (Color.orange(module)) + ".");
        }).on('module-installed', function(module) {
          Log.stop();
          return Log.inner("" + (Color.orange(module)) + " installed.");
        }).build().then(function() {
          tinylr.changed('/');
          resolve();
          Log.stop();
          Log.br();
          Log.inner("" + (Color.violet(moment().format('hh:mm:ss'))) + " | App built.");
          return Log.br();
        })["catch"](function(err) {
          Log.error('Could not compile', false);
          Log.innerError(err, false);
          Log.br();
          return _this.run();
        });
      };
    })(this));
  };

  return Watcher;

})();
