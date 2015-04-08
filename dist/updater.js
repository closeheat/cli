var Color, Config, Log, Promise, Updater, checkUpdate;

checkUpdate = require('check-update');

Promise = require('bluebird');

Config = require('./config');

Log = require('./log');

Color = require('./color');

module.exports = Updater = (function() {
  function Updater() {}

  Updater.prototype.update = function() {
    return this.exec().then((function(_this) {
      return function() {
        return _this.saveLastCheckTime();
      };
    })(this));
  };

  Updater.prototype.exec = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (_this.longTimeNoUpdate()) {
          return _this.checkForUpdate().then(function(update_data) {
            if (update_data.exists) {
              _this.askForUpdate(update_data.version);
            }
            return resolve();
          });
        } else {
          return resolve();
        }
      };
    })(this));
  };

  Updater.prototype.longTimeNoUpdate = function() {
    var last_update_check;
    last_update_check = Config.fileContents().last_update_check || Date.now();
    return Date.now() - last_update_check > 1 * 24 * 60 * 60;
  };

  Updater.prototype.saveLastCheckTime = function() {
    return Config.update('last_update_check', Date.now());
  };

  Updater.prototype.askForUpdate = function(version) {
    Log.p("A new version (" + version + ") of closeheat is available. Run " + (Color.violet('npm update closeheat -g')) + " to update.");
    return Log.br();
  };

  Updater.prototype.checkForUpdate = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return checkUpdate({
          packageName: 'closeheat'
        }, function(err, latest) {
          if (err) {
            return reject();
          } else {
            return resolve({
              exists: Config.version() < latest,
              version: latest
            });
          }
        });
      };
    })(this));
  };

  return Updater;

})();
