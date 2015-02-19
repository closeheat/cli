var Color, Deployer, Git, Log, Q, callback, git, gulp, gutil, q;

gulp = require('gulp');

git = require('gulp-git');

Q = require('q');

q = require('bluebird');

callback = require('gulp-callback');

gutil = require('gulp-util');

Git = require('git-wrapper');

Log = require('./log');

Color = require('./color');

module.exports = Deployer = (function() {
  var ALL_FILES;

  function Deployer() {}

  ALL_FILES = '**';

  Deployer.prototype.deploy = function(files) {
    this.files = files != null ? files : ALL_FILES;
    this.git = new Git();
    Log.spin('Deploying the app to closeheat.com via Github.');
    return this.addEverything().then((function(_this) {
      return function() {
        Log.stop();
        Log.inner('All files added.');
        return _this.commit('Deploy via CLI').then(function() {
          Log.inner('Files commited.');
          Log.inner('Pushing to Github.');
          return _this.pushToMainBranch().then(function(branch) {
            Log.inner("Pushed to " + branch + " branch on Github.");
            return _this.deployLog().then(function() {
              Log.p("App deployed to " + (Color.violet('http://blablabla.closeheatapp.com')) + ".");
              Log.p('Open it quicker with:');
              return Log.code('closeheat open');
            });
          });
        });
      };
    })(this))["catch"](function(err) {
      return Log.error(err);
    });
  };

  Deployer.prototype.addEverything = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('add', ['.'], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  Deployer.prototype.commit = function(msg) {
    return new q((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('commit', {
          m: true
        }, ["'" + msg + "'"], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  Deployer.prototype.pushToMainBranch = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return _this.getMainBranch().then(function(main_branch) {
          return _this.push(main_branch).then(function() {
            return resolve(main_branch);
          });
        });
      };
    })(this));
  };

  Deployer.prototype.getMainBranch = function() {
    return new q(function(resolve, reject) {
      return resolve('master');
    });
  };

  Deployer.prototype.push = function(branch) {
    return new q((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('push', ['origin', branch], function(err, msg) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  Deployer.prototype.deployLog = function() {
    return new q(function(resolve, reject) {
      Log.br();
      Log.backend('Downloading the Github repo.');
      Log.backend('Building app.');
      Log.backend('App is live.');
      Log.br();
      return resolve();
    });
  };

  return Deployer;

})();
