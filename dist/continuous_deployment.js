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
    Log.p('You are about to publish a new website.');
    return this.run();
  };

  ContinuousDeployment.prototype.promisify = function(result) {
    return new Promise(function(resolve, reject) {
      return resolve(result);
    });
  };

  ContinuousDeployment.prototype.useOrGet = function(opts, thing, get) {
    if (opts[thing]) {
      return this.promisify(opts[thing]);
    } else {
      console.log('gettin');
      console.log(get);
      return get;
    }
  };

  ContinuousDeployment.prototype.run = function(opts) {
    var runner, seq;
    if (opts == null) {
      opts = {};
    }
    seq = [
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
    runner = Promise.reduce(seq, function(opts, obj) {
      console.log(arguments);
      return obj.fn(opts).then(function(result) {
        return result;
      });
    }, {});
    return runner.then(function() {
      console.log('done');
      return console.log(arguments);
    });
  };

  ContinuousDeployment.prototype.exec = function(opts) {
    return this.run(opts).then(function(data) {
      console.log(data);
      console.log('ehe');
      return console.log(arguments);
    }).fail((function(_this) {
      return function(err) {
        console.log('FAIL');
        return _this.exec({
          validated_slug: 'hello',
          repo: 'hello'
        }).then(function() {
          return console.log('OTHER');
        });
      };
    })(this));
  };

  ContinuousDeployment.prototype.ensureNoWebsite = function(data) {
    return GitRepository.exists().then((function(_this) {
      return function(repo) {
        if (!repo.exists) {
          return;
        }
        return Website.exists(repo.name).then(function(website) {
          if (!website.exists) {
            return;
          }
          return _this.exec({
            ensure_no_website: website_exists
          });
        });
      };
    })(this));
  };

  ContinuousDeployment.prototype.configure = function() {
    return this.ensureWebsiteDoesntExist().then(function() {
      return SlugManager.choose().then(function(slug) {
        return GitHubManager.choose(slug).then(function(repo) {
          return AppManager.create(slug, repo);
        });
      });
    });
  };

  ContinuousDeployment.prototype.ensureWebsiteDoesntExist = function() {
    return GitRepository.exists().then((function(_this) {
      return function(repo) {
        if (!repo.exists) {
          return;
        }
        return Website.exists(repo.name).then(function(website) {
          if (!website.exists) {
            return;
          }
          if (website.exists) {
            return _this.exists(website.slug, website.repo);
          }
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
