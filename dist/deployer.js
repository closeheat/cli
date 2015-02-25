var Authorized, Color, Deployer, Git, Initializer, Log, Promise, Urls, inquirer, open, _;

Promise = require('bluebird');

Git = require('git-wrapper');

inquirer = require('inquirer');

_ = require('lodash');

open = require('open');

Initializer = require('./initializer');

Authorized = require('./authorized');

Urls = require('./urls');

Log = require('./log');

Color = require('./color');

module.exports = Deployer = (function() {
  var GITHUB_REPO_REGEX;

  function Deployer() {
    this.git = new Git();
  }

  Deployer.prototype.deploy = function() {
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
            return _this.deployLog().then(function(deployed_name) {
              var url;
              url = "http://" + deployed_name + ".closeheatapp.com";
              Log.p("App deployed to " + (Color.violet(url)) + ".");
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
    return new Promise((function(_this) {
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
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('commit', {
          m: true
        }, ["'" + msg + "'"], function(err, resp) {
          return resolve();
        });
      };
    })(this));
  };

  Deployer.prototype.pushToMainBranch = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.ensureAppAndRepoExist().then(function() {
          return _this.getMainBranch().then(function(main_branch) {
            return _this.push(main_branch).then(function() {
              return resolve(main_branch);
            });
          });
        });
      };
    })(this));
  };

  Deployer.prototype.ensureAppAndRepoExist = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.repoExist().then(function(exist) {
          if (exist) {
            return resolve();
          } else {
            return _this.askToCreateApp().then(resolve);
          }
        });
      };
    })(this));
  };

  Deployer.prototype.askToCreateApp = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return inquirer.prompt({
          message: 'This app is not deployed yet. Would you like create a new closeheat app and deploy via Github?',
          type: 'confirm',
          name: 'create'
        }, function(answer) {
          if (answer.create) {
            return new Initializer().init().then(resolve);
          } else {
            return Log.error('You cannot deploy this app without the closeheat backend and Github setup');
          }
        });
      };
    })(this));
  };

  Deployer.prototype.repoExist = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('remote', function(err, msg) {
          var origin;
          if (err) {
            return reject(err);
          }
          origin = msg.match(/origin/);
          return resolve(origin);
        });
      };
    })(this));
  };

  Deployer.prototype.getMainBranch = function() {
    return new Promise(function(resolve, reject) {
      return resolve('master');
    });
  };

  Deployer.prototype.push = function(branch) {
    return new Promise((function(_this) {
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
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.getOriginRepo().then(function(repo) {
          return _this.pollAndLogUntilDeployed(repo).then(function() {
            Log.br();
            return resolve(_this.slug);
          });
        });
      };
    })(this));
  };

  Deployer.prototype.pollAndLogUntilDeployed = function(repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        _this.status = 'none';
        Log.br();
        return _this.promiseWhile((function() {
          return _this.status !== 'deployed';
        }), (function() {
          return _this.requestAndLogStatus(repo);
        })).then(resolve);
      };
    })(this));
  };

  Deployer.prototype.promiseWhile = function(condition, action) {
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

  Deployer.prototype.requestAndLogStatus = function(repo) {
    return Authorized.request({
      url: Urls.deployStatus(),
      repo: repo,
      method: 'post',
      json: true
    }, (function(_this) {
      return function(err, resp) {
        if (resp.body.status !== _this.status) {
          Log.fromBackendStatus(resp.body.status);
        }
        _this.status = resp.body.status;
        return _this.slug = resp.body.slug;
      };
    })(this));
  };

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/;

  Deployer.prototype.getOriginRepo = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('remote', ['--verbose'], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.match(GITHUB_REPO_REGEX)[1]);
        });
      };
    })(this));
  };

  Deployer.prototype.open = function() {
    return this.getOriginRepo().then(function(repo) {
      return Authorized.request({
        url: Urls.deployedSlug(),
        repo: repo,
        method: 'post',
        json: true
      }, (function(_this) {
        return function(err, resp) {
          var url;
          url = "http://" + resp.body.slug + ".closeheatapp.com";
          Log.p("Opening your app at " + url + ".");
          return open(url);
        };
      })(this));
    });
  };

  return Deployer;

})();
