var Authorized, BackendLogger, DeployLog, Git, Log, Promise, Urls, Website, _,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Promise = require('bluebird');

_ = require('lodash');

Git = require('git-wrapper');

Log = require('./log');

Authorized = require('./authorized');

Urls = require('./urls');

BackendLogger = require('./backend_logger');

Website = require('./website');

module.exports = DeployLog = (function() {
  function DeployLog() {
    this.requestAndLogStatus = bind(this.requestAndLogStatus, this);
    this.backend_logger = new BackendLogger();
    this.git = new Git();
  }

  DeployLog.prototype.fromCurrentCommit = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.pollAndLogUntilDeployed().then(function() {
          Log.br();
          return resolve(_this.slug);
        });
      };
    })(this));
  };

  DeployLog.prototype.pollAndLogUntilDeployed = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        _this.status = 'none';
        Log.br();
        return _this.promiseWhile((function() {
          return !_.contains(['success', 'failed', null], _this.status);
        }), (function() {
          return _this.requestAndLogStatus();
        })).then(resolve);
      };
    })(this));
  };

  DeployLog.prototype.requestAndLogStatus = function() {
    return Website.get().then((function(_this) {
      return function(website) {
        return _this.getSha().then(function(sha) {
          return Authorized.post(Urls.buildForCLI(website.slug), {
            commit_sha: sha
          }).then(function(resp) {
            var build;
            build = resp.build;
            _this.backend_logger.log(build);
            return _this.status = build.status;
          });
        });
      };
    })(this));
  };

  DeployLog.prototype.getSha = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('rev-parse', ['HEAD'], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.trim());
        });
      };
    })(this));
  };

  DeployLog.prototype.promiseWhile = function(condition, action) {
    return new Promise(function(resolve, reject) {
      var repeat;
      repeat = function() {
        if (!condition()) {
          return resolve();
        }
        return Promise.cast(action()).then(function() {
          return _.delay(repeat, 1000);
        })["catch"](reject);
      };
      return process.nextTick(repeat);
    });
  };

  return DeployLog;

})();
