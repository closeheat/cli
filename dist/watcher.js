var Builder, Color, Log, Promise, Watcher, chokidar, moment, path, rimraf, tinylr, util, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

chokidar = require('chokidar');

util = require('util');

rimraf = require('rimraf');

path = require('path');

tinylr = require('tiny-lr');

Promise = require('bluebird');

moment = require('moment');

_ = require('lodash');

Builder = require('closeheat-builder');

Log = require('./log');

Color = require('./color');

module.exports = Watcher = (function() {
  function Watcher(src, dist) {
    this.src = src;
    this.dist = dist;
    this.build = __bind(this.build, this);
    this.dist_app = path.join(this.dist, 'app');
    this.watcher = chokidar.watch(this.src, {
      ignored: /.git/,
      ignoreInitial: true
    });
  }

  Watcher.prototype.run = function() {
    return this.watcher.on('error', function(err) {
      return Log.error(err);
    }).on('all', _.throttle(((function(_this) {
      return function(e, file) {
        return _this.build(e, file);
      };
    })(this)), 2000));
  };

  Watcher.prototype.build = function(e, file) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (file) {
          _this.logFileChanged(file);
        }
        return _this.execBuild(resolve, reject);
      };
    })(this));
  };

  Watcher.prototype.execBuild = function(resolve, reject) {
    Log.spin('Building the app.');
    rimraf.sync(this.dist_app);
    return new Builder(this.src, this.dist).on('module-detected', function(module) {
      return Log.spin("New require detected. Installing " + (Color.orange(module)) + ".");
    }).on('module-installed', function(module) {
      Log.stop();
      return Log.inner("" + (Color.orange(module)) + " installed.");
    }).build().then(function() {
      tinylr.changed('/');
      resolve();
      Log.stop();
      return Log.inner("" + (Color.violet(moment().format('hh:mm:ss'))) + " | App built.");
    })["catch"](function(err) {
      Log.error('Could not compile', false);
      Log.innerError(err, false);
      return Log.br();
    });
  };

  Watcher.prototype.logFileChanged = function(file) {
    var relative;
    relative = path.relative(this.src, file);
    Log.stop();
    Log.br();
    return Log.doneLine("" + relative + " changed.");
  };

  return Watcher;

})();
