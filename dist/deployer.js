var Authorized, Color, DeployLog, Deployer, Git, Initializer, Log, Notifier, Promise, Urls, _, fs, inquirer, open;

Promise = require('bluebird');

Git = require('git-wrapper');

inquirer = require('inquirer');

_ = require('lodash');

open = require('open');

fs = require('fs.extra');

Initializer = require('./initializer');

Authorized = require('./authorized');

Urls = require('./urls');

DeployLog = require('./deploy_log');

Log = require('./log');

Color = require('./color');

Notifier = require('./notifier');

module.exports = Deployer = (function() {
  var GITHUB_REPO_REGEX;

  function Deployer() {
    this.git = new Git();
  }

  Deployer.prototype.deploy = function() {
    Log.spin('Deploying the app to closeheat.com via GitHub.');
    return this.initGit().then((function(_this) {
      return function() {
        return _this.addEverything().then(function() {
          Log.stop();
          Log.inner('All files added.');
          return _this.commit('Deploy via CLI').then(function() {
            Log.inner('Files commited.');
            Log.inner('Pushing to GitHub.');
            return _this.pushToMainBranch().then(function(branch) {
              Log.inner("Pushed to " + branch + " branch on GitHub.");
              return new DeployLog().fromCurrentCommit().then(function(deployed_name) {
                var url;
                Notifier.notify('app_deploy', deployed_name);
                url = "http://" + deployed_name + ".closeheatapp.com";
                Log.p("App deployed to " + (Color.violet(url)) + ".");
                Log.p('Open it quicker with:');
                Log.code("cd " + deployed_name);
                return Log.code('closeheat open');
              });
            });
          });
        });
      };
    })(this))["catch"](function(err) {
      return Log.error(err);
    })["finally"](function() {});
  };

  Deployer.prototype.initGit = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (fs.existsSync('.git')) {
          return resolve();
        } else {
          return _this.git.exec('init', function(err, resp) {
            return resolve();
          });
        }
      };
    })(this));
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
          message: 'This app is not deployed yet. Would you like create a new closeheat app and deploy via GitHub?',
          type: 'confirm',
          name: 'create'
        }, function(answer) {
          if (answer.create) {
            return new Initializer().init().then(resolve);
          } else {
            return Log.error('You cannot deploy this app without the closeheat backend and GitHub setup');
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
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('symbolic-ref', ['--short', 'HEAD'], function(err, msg) {
          if (err) {
            return reject(err);
          }
          return resolve(msg.trim());
        });
      };
    })(this));
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
    return this.getOriginRepo().then((function(_this) {
      return function(repo) {
        return _this.getSlug(repo).then(function(slug) {
          var url;
          url = "http://" + slug + ".closeheatapp.com";
          Log.p("Opening your app at " + url + ".");
          return open(url);
        });
      };
    })(this));
  };

  Deployer.prototype.getSlug = function(repo) {
    return new Promise(function(resolve, reject) {
      return Authorized.request({
        url: Urls.deployedSlug(),
        qs: {
          repo: repo
        },
        method: 'post',
        json: true
      }, function(err, resp) {
        var msg;
        if (err) {
          return reject(err);
        }
        if (_.isUndefined(resp.body.slug)) {
          msg = "Could not find your closeheat app with GitHub repo '" + repo + "'. Please deploy the app via UI";
          return Log.error(msg);
        }
        return resolve(resp.body.slug);
      });
    });
  };

  return Deployer;

})();
