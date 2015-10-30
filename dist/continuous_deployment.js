var AppManager, Authorized, Authorizer, Color, ContinuousDeployment, DeployLog, Git, GitHubManager, Initializer, Log, Notifier, Promise, SlugManager, Urls, _, fs, inquirer, open;

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

SlugManager = require('./slug_manager');

GitHubManager = require('./github_manager');

AppManager = require('./app_manager');

module.exports = ContinuousDeployment = (function() {
  function ContinuousDeployment() {
    this.git = new Git();
  }

  ContinuousDeployment.prototype.start = function() {
    Log.p('You are about to publish a new website.');
    return this.configure();
  };

  ContinuousDeployment.prototype.configure = function() {
    return SlugManager.choose().then((function(_this) {
      return function(slug) {
        return GitHubManager.repo(slug).then(function(repo) {
          return AppManager.create(slug, repo).then(_this.success)["catch"](_this.exists);
        });
      };
    })(this));
  };

  ContinuousDeployment.prototype.exists = function(result) {
    Log.p("Hey there! This folder is already published to closeheat.");
    Log.p("It is available at " + (Color.violet(result.slug + ".closeheatapp.com")) + ".");
    Log.p("You can open it swiftly by typing " + (Color.violet('closeheat open')) + ".");
    Log.br();
    Log.p("It has a continuous deployment setup from GitHub at " + result.repo);
    Log.br();
    Log.p("Anyways - if you'd like to publish your current code changes, just type:");
    Log.p(Color.violet('closeheat quick-publish'));
    return Log.p("Doing that will commit and push all of your changes to the GitHub repository and publish it.");
  };

  return ContinuousDeployment;

})();
