var Authorized, BackendLogger, DeployLog, Git, Log, Promise, Urls, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Promise = require('bluebird');

_ = require('lodash');

Git = require('git-wrapper');

Log = require('./log');

Authorized = require('./authorized');

Urls = require('./urls');

BackendLogger = require('./backend_logger');

module.exports = DeployLog = (function() {
  function DeployLog() {
    this.requestAndLogStatus = __bind(this.requestAndLogStatus, this);
    var Deployer;
    Deployer = require('./deployer');
    this.deployer = new Deployer();
    this.backend_logger = new BackendLogger();
    this.git = new Git();
  }

  DeployLog.prototype.fromCurrentCommit = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.deployer.getOriginRepo().then(function(repo) {
          return _this.pollAndLogUntilDeployed(repo).then(function() {
            Log.br();
            return resolve(_this.slug);
          });
        });
      };
    })(this));
  };

  DeployLog.prototype.pollAndLogUntilDeployed = function(repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        _this.status = 'none';
        Log.br();
        return _this.promiseWhile((function() {
          return !_.contains(['success', 'failed', null], _this.status);
        }), (function() {
          return _this.requestAndLogStatus(repo);
        })).then(resolve);
      };
    })(this));
  };

  DeployLog.prototype.requestAndLogStatus = function(repo) {
    return this.getSha().then((function(_this) {
      return function(sha) {
        return _this.deployer.getSlug(repo).then(function(slug) {
          _this.slug = slug;
          return Authorized.request({
            url: Urls.buildForCLI(slug),
            qs: {
              commit_sha: sha
            },
            method: 'get',
            json: true
          }, function(err, resp) {
            var build;
            if (resp.statusCode === 404) {
              return Log.error(resp.body.message);
            } else if (resp.statusCode === 200) {
              build = resp.body.build;
              _this.backend_logger.log(build);
              return _this.status = build.status;
            } else {
              return Log.error("Unknown backend error. We're fixing this already.");
            }
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
