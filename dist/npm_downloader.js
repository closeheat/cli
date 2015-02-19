var Color, Log, NPM, NpmDownloader, fs, path, q, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

q = require('bluebird');

_ = require('lodash');

path = require('path');

NPM = require('machinepack-npm');

Log = require('./log');

Color = require('./color');

module.exports = NpmDownloader = (function() {
  function NpmDownloader(dist, modules) {
    this.dist = dist;
    this.modules = modules;
    this.missing = __bind(this.missing, this);
    this.downloadAll = __bind(this.downloadAll, this);
  }

  NpmDownloader.prototype.downloadAll = function() {
    var module_downloads;
    if (_.isEmpty(this.missing())) {
      return new q(function(resolve, reject) {
        return resolve();
      });
    }
    module_downloads = _.map(this.missing(), (function(_this) {
      return function(module) {
        return _this.download(module);
      };
    })(this));
    console.log('wha');
    console.log(module_downloads);
    console.log('up');
    return q.when.apply(q, module_downloads);
  };

  NpmDownloader.prototype.missing = function() {
    return _.reject(_.uniq(this.modules), (function(_this) {
      return function(module) {
        return fs.existsSync(path.join(_this.dist, 'node_modules', module));
      };
    })(this));
  };

  NpmDownloader.prototype.download = function(module) {
    return new q((function(_this) {
      return function(resolve, reject) {
        Log.spin("New require detected. Installing " + (Color.orange(module)) + ".");
        return NPM.installPackage({
          name: module,
          loglevel: 'silent',
          prefix: _this.dist
        }).exec({
          error: function(err) {
            Log.stop();
            return reject(err);
          },
          success: function(name) {
            Log.stop();
            Log.inner("" + (Color.orange(name)) + " installed.");
            return resolve();
          }
        });
      };
    })(this));
  };

  return NpmDownloader;

})();
