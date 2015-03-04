var BackendLogger, Log, _;

Log = require('./log');

_ = require('lodash');

module.exports = BackendLogger = (function() {
  function BackendLogger() {
    this.old_log = [];
    this["try"] = 0;
    this.last_status = 'none';
  }

  BackendLogger.prototype.log = function(build) {
    _.each(this.diff(build), Log.backend);
    this.old_log = build.log;
    return this.checkTimeout(build);
  };

  BackendLogger.prototype.checkTimeout = function(build) {
    if (build.status === this.status) {
      if (this["try"] > 10) {
        Log.error('Deployment timed out.');
      }
      return this["try"] += 1;
    } else {
      return this.last_status = build.status;
    }
  };

  BackendLogger.prototype.diff = function(build) {
    return _.select(build.log, (function(_this) {
      return function(new_data) {
        return !_.contains(_.map(_this.old_log, 'message'), new_data.message);
      };
    })(this));
  };

  BackendLogger.fromBackendStatus = function(status, msg) {
    if (status === 'download_github_repo') {
      return this.backend('Downloading the GitHub repo.');
    } else if (status === 'build') {
      return this.backend('Building app.');
    } else if (status === 'deployed') {
      return this.backend('App is live.');
    } else if (status === 'error') {
      if (msg) {
        return this.error(msg);
      } else {
        return this.backendError();
      }
    } else {
      return this.backend('Unknown status.');
    }
  };

  return BackendLogger;

})();
