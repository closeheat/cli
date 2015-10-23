var Builder, Color, Dirs, Log, Promise, Watcher, _, gulp, moment, path, rimraf, tinylr, util,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

util = require('util');

rimraf = require('rimraf');

path = require('path');

tinylr = require('tiny-lr');

Promise = require('bluebird');

moment = require('moment');

_ = require('lodash');

gulp = require('gulp');

Builder = require('closeheat-builder');

Dirs = require('./dirs');

Log = require('./log');

Color = require('./color');

module.exports = Watcher = (function() {
  function Watcher(src, dist) {
    this.src = src;
    this.dist = dist;
    this.build = bind(this.build, this);
    this.watcher = gulp.watch(path.join(this.src, '**/*.*'));
  }

  Watcher.prototype.run = function() {
    var debouncedBuild;
    debouncedBuild = _.debounce(this.build, 2500, {
      leading: true
    });
    return this.watcher.on('error', function(err) {
      return Log.error(err);
    }).on('change', debouncedBuild).on('all', debouncedBuild);
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
    rimraf.sync(this.dist);
    return new Builder(this.src, this.dist, Dirs.buildTmp()).on('module-detected', function(module) {
      return Log.spin("New require detected. Installing " + (Color.orange(module)) + ".");
    }).on('module-installed', function(module) {
      Log.stop();
      return Log.inner((Color.orange(module)) + " installed.");
    }).build().then(function() {
      tinylr.changed('/');
      resolve();
      Log.stop();
      return Log.inner((Color.violet(moment().format('hh:mm:ss'))) + " | App built.");
    })["catch"](function(err) {
      Log.error('Could not compile', false, err);
      return Log.br();
    });
  };

  Watcher.prototype.logFileChanged = function(file) {
    var relative;
    relative = path.relative(this.src, file);
    Log.stop();
    Log.br();
    return Log.doneLine(relative + " changed.");
  };

  return Watcher;

})();
