var Authorized, Authorizer, Color, DeployLog, Git, Initializer, Log, Notifier, Promise, Publisher, Urls, _, fs, inquirer, open;

Promise = require('bluebird');

inquirer = require('inquirer');

_ = require('lodash');

open = require('open');

fs = require('fs.extra');

Git = require('./git');

Initializer = require('./initializer');

Authorized = require('./authorized');

Authorizer = require('./authorizer');

Urls = require('./urls');

DeployLog = require('./deploy_log');

Log = require('./log');

Color = require('./color');

Notifier = require('./notifier');

module.exports = Publisher = (function() {
  var GITHUB_REPO_REGEX;

  function Publisher() {
    this.git = new Git();
  }

  Publisher.prototype.newWebsite = function() {
    var authorizer;
    Log.p('You are about to publish a new website.');
    authorizer = new Authorizer();
    return authorizer.ensureGitHubAuthorized().then((function(_this) {
      return function() {
        return _this.checkContinousDeliveryExists().then(function(result) {
          if (result.exists) {
            Log.p("Hey there! This folder is already published to closeheat.");
            Log.p("It is available at " + (Color.violet(result.slug + ".closeheatapp.com")) + ".");
            Log.p("You can open it swiftly by typing " + (Color.violet('closeheat open')) + ".");
            Log.br();
            Log.p("It has a continuous deployment setup from GitHub at " + result.repo);
            Log.br();
            Log.p("Anyways - if you'd like to publish your current code changes, just type:");
            Log.p(Color.violet('closeheat quick-publish'));
            return Log.p("Doing that will commit and push all of your changes to the GitHub repository and publish it.");
          } else {
            return _this.setupContinousDelivery();
          }
        });
      };
    })(this));
  };

  Publisher.prototype.checkContinousDeliveryExists = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (!fs.existsSync('.git')) {
          return resolve({
            exists: false
          });
        }
        return _this.getGitHubRepoUrl().then(function(repo) {
          if (!repo) {
            return resolve({
              exists: false
            });
          }
          return Authorized.request({
            url: Urls.deployedSlug(),
            qs: {
              repo: repo
            },
            method: 'post',
            json: true
          }, function(err, resp) {
            if (err) {
              return reject(err);
            }
            if (!resp.body.exists) {
              return resolve({
                exists: false
              });
            }
            return resolve({
              exists: true,
              slug: resp.body.slug,
              repo: repo
            });
          });
        });
      };
    })(this));
  };

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/;

  Publisher.prototype.getGitHubRepoUrl = function() {
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

  Publisher.prototype.setupContinousDelivery = function() {
    return this.askSlug().then((function(_this) {
      return function(slug) {
        return _this.getGitHubRepoUrl().then(function(repo_url) {
          if (repo_url) {
            return _this.askReuseGitHubRepo(repo_url).then(function(reuse) {
              if (reuse) {
                return _this.attachGitHubHooks(repo_url, slug).then(function() {
                  return _this.successfulSetup(repo_url, slug);
                });
              } else {
                return _this.createNewGitHubRepo(slug);
              }
            });
          } else {
            return _this.createNewGitHubRepo(slug);
          }
        });
      };
    })(this));
  };

  Publisher.prototype.createNewGitHubRepo = function(slug) {
    return this.askNewRepoName().then((function(_this) {
      return function(repo) {
        return _this.publishWithGitHubRepo(repo, slug).then(function() {
          return _this.successfulSetup(repo, slug);
        });
      };
    })(this));
  };

  Publisher.prototype.publishWithGitHubRepo = function(repo, slug) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.publishNewWebsite(),
          qs: {
            repo: slug,
            slug: slug
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.body.success);
        });
      };
    })(this));
  };

  Publisher.prototype.successfulSetup = function(repo, slug) {
    Log.p('Success!');
    Log.p("Your website " + (Color.violet(slug + ".closeheatapp.com")) + " is now published.");
    Log.br();
    Log.p("GitHub repository " + repo + " is setup for continuous deployment.");
    Log.p("Every change to master branch will be immediately published.");
    Log.br();
    Log.p("The logs of each deploy are available with " + (Color.violet('closeheat log')) + ".");
    Log.p("It's useful to have them right after your " + (Color.violet('git push')) + " with " + (Color.violet('git push origin master && closeheat log')));
    Log.br();
    Log.p("To set up a custom domain or change a public directory type:");
    return Log.code('closeheat settings');
  };

  Publisher.prototype.askSlug = function() {
    return this.suggestDefaultSlug().then((function(_this) {
      return function(slug) {
        return new Promise(function(resolve, reject) {
          return inquirer.prompt({
            message: 'What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later)',
            name: 'slug',
            "default": slug
          }, function(answer) {
            return _this.isFreeSlug(answer.slug).then(function(is_free) {
              if (is_free) {
                return resolve(answer.slug);
              } else {
                Log.p('This slug is used');
                return _this.askSlug();
              }
            });
          });
        });
      };
    })(this));
  };

  Publisher.prototype.askNewRepoName = function() {
    return this.suggestDefaultRepo().then((function(_this) {
      return function(repo) {
        return new Promise(function(resolve, reject) {
          return inquirer.prompt({
            message: 'What is the GitHub repository would you like to create for this website? Ex. Nedomas/NAME?',
            name: 'repo',
            "default": repo
          }, function(answer) {
            return _this.isFreeRepo(answer.repo).then(function(is_free) {
              if (is_free) {
                return resolve(answer.repo);
              } else {
                Log.p('You already have a GitHub repo with this name.');
                return _this.askSlug();
              }
            });
          });
        });
      };
    })(this));
  };

  Publisher.prototype.isFreeSlug = function(slug) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.isFreeSlug(),
          qs: {
            slug: slug
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.body.free);
        });
      };
    })(this));
  };

  Publisher.prototype.isFreeRepo = function(repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.isFreeRepo(),
          qs: {
            repo: repo
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.body.free);
        });
      };
    })(this));
  };

  Publisher.prototype.folder = function() {
    return _.last(process.cwd().split('/'));
  };

  Publisher.prototype.suggestDefaultRepo = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.suggestRepo(),
          qs: {
            folder: _this.folder()
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.body.repo);
        });
      };
    })(this));
  };

  Publisher.prototype.suggestDefaultSlug = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.suggestSlug(),
          qs: {
            folder: _this.folder()
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp.body.slug);
        });
      };
    })(this));
  };

  Publisher.prototype.attachGitHubHooks = function(repo_url, slug) {
    return new Promise(function(resolve, reject) {
      return Authorized.request({
        url: Urls.setupExistingRepo(),
        qs: {
          repo: repo_url,
          slug: slug
        },
        method: 'post',
        json: true
      }, function(err, resp) {
        if (err) {
          return reject(err);
        }
        return resolve();
      });
    });
  };

  Publisher.prototype.askReuseGitHubRepo = function(repo_name) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return inquirer.prompt({
          message: "Would you like to use your existing " + repo_name + " GitHub repository repo for continuos delivery?",
          type: 'confirm',
          name: 'reuse'
        }, function(answer) {
          return resolve(answer.reuse);
        });
      };
    })(this));
  };

  Publisher.prototype.quickPublish = function() {
    Log.spin('Deploying the app to closeheat.com via GitHub.');
    return this.initGit().then((function(_this) {
      return function() {
        return _this.addEverything().then(function() {
          Log.stop();
          Log.inner('All files added.');
          return _this.commit('Quick deploy').then(function() {
            Log.inner('Files commited.');
            Log.inner('Pushing to GitHub.');
            return _this.pushToMainBranch().then(function(branch) {
              Log.inner("Pushed to " + branch + " branch on GitHub.");
              return new DeployLog().fromCurrentCommit().then(function(deployed_name) {
                var url;
                Notifier.notify('app_deploy', deployed_name);
                url = "http://" + deployed_name + ".closeheatapp.com";
                Log.p("Website published at " + (Color.violet(url)) + ".");
                Log.p('Open it with:');
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

  Publisher.prototype.initGit = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (fs.existsSync('.git')) {
          return resolve();
        }
        return _this.git.exec('init', function(err, resp) {
          return resolve();
        });
      };
    })(this));
  };

  Publisher.prototype.addEverything = function() {
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

  Publisher.prototype.commit = function(msg) {
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

  Publisher.prototype.pushToMainBranch = function() {
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

  Publisher.prototype.ensureAppAndRepoExist = function() {
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

  Publisher.prototype.askToCreateApp = function() {
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

  Publisher.prototype.repoExist = function() {
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

  Publisher.prototype.getMainBranch = function() {
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

  Publisher.prototype.push = function(branch) {
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

  Publisher.prototype.getOriginRepo = function() {
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

  Publisher.prototype.open = function() {
    return this.getOriginRepo().then((function(_this) {
      return function(repo) {
        return _this.getSlug(repo).then(function(slug) {
          var url;
          url = "http://" + slug + ".closeheatapp.com";
          Log.p("Opening your app at " + url + ".");
          if (!process.env.CLOSEHEAT_TEST) {
            return open(url);
          }
        });
      };
    })(this));
  };

  Publisher.prototype.getSlug = function(repo) {
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

  return Publisher;

})();
