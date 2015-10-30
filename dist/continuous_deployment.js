var Authorized, Authorizer, Color, ContinuousDeployment, DeployLog, Git, GitHubManager, Initializer, Log, Notifier, Promise, SlugManager, Urls, Website, _, fs, inquirer, open, shepherd;

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

Website = require('./website');

shepherd = require("shepherd");

module.exports = ContinuousDeployment = (function() {
  function ContinuousDeployment() {
    this.git = new Git();
  }

  ContinuousDeployment.prototype.start = function() {
    return this.ensureNoWebsite().then((function(_this) {
      return function() {
        Log.p('You are about to publish a new website.');
        return _this.run();
      };
    })(this));
  };

  ContinuousDeployment.prototype.steps = function() {
    return [
      {
        key: 'slug',
        fn: SlugManager.choose
      }, {
        key: 'repo',
        fn: GitHubManager.choose
      }, {
        key: 'website',
        fn: Website.create
      }
    ];
  };

  ContinuousDeployment.prototype.unfullfilledSteps = function(opts) {
    return _.reject(this.steps(), function(obj) {
      return _.include(_.keys(opts), obj.key);
    });
  };

  ContinuousDeployment.prototype.run = function(opts) {
    var runner;
    if (opts == null) {
      opts = {};
    }
    if (_.isEmpty(this.unfullfilledSteps(opts))) {
      return opts;
    }
    runner = Promise.reduce(this.unfullfilledSteps(opts), function(new_opts, obj) {
      console.log(arguments);
      return obj.fn(new_opts).then(function(result) {
        console.log('last');
        console.log(result);
        return result;
      });
    }, {});
    return runner.then((function(_this) {
      return function(opts) {
        return _this.run(opts);
      };
    })(this));
  };

  ContinuousDeployment.prototype.ensureNoWebsite = function(data) {
    return Website.get().then((function(_this) {
      return function(website) {
        if (!website.exists) {
          return;
        }
        return _this.exists(website);
      };
    })(this));
  };

  ContinuousDeployment.prototype.exists = function(website) {
    Log.p("Hey there! This folder is already published to closeheat.");
    Log.p("It is available at " + (Color.violet(website.slug + ".closeheatapp.com")) + ".");
    Log.p("You can open it swiftly by typing " + (Color.violet('closeheat open')) + ".");
    Log.br();
    Log.p("It has a continuous deployment setup from GitHub at " + website.repo);
    Log.br();
    Log.p("Anyways - if you'd like to publish your current code changes, just type:");
    Log.p(Color.violet('closeheat quick-publish'));
    Log.p("Doing that will commit and push all of your changes to the GitHub repository and publish it.");
    return process.exit();
  };

  ContinuousDeployment.prototype.success = function(opts) {
    var repo, slug;
    slug = opts.slug;
    repo = opts.repo;
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

  return ContinuousDeployment;

})();
