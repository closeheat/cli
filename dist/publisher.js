var Color, GitHubManager, GitRepository, Log, Promise, Publisher, SlugManager, Website, _;

Promise = require('bluebird');

_ = require('lodash');

Log = require('./log');

Color = require('./color');

SlugManager = require('./slug_manager');

GitHubManager = require('./github_manager');

Website = require('./website');

GitRepository = require('./git_repository');

module.exports = Publisher = (function() {
  function Publisher() {}

  Publisher.prototype.start = function() {
    return this.ensureNoWebsite().then((function(_this) {
      return function() {
        Log.p('You are about to publish a new website.');
        return _this.run().then(_this.success);
      };
    })(this));
  };

  Publisher.prototype.steps = function() {
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
      }, {
        key: 'remote',
        fn: GitRepository.ensureRemote
      }
    ];
  };

  Publisher.prototype.unfullfilledSteps = function(opts) {
    return _.select(this.steps(), function(obj) {
      return !opts[obj.key];
    });
  };

  Publisher.prototype.run = function(opts) {
    var runner;
    if (opts == null) {
      opts = {};
    }
    if (_.isEmpty(this.unfullfilledSteps(opts))) {
      return opts;
    }
    runner = Promise.reduce(this.unfullfilledSteps(opts), function(new_opts, obj) {
      return obj.fn(new_opts).then(function(result) {
        return result;
      });
    }, opts);
    return runner.then((function(_this) {
      return function(opts) {
        return _this.run(opts);
      };
    })(this));
  };

  Publisher.prototype.ensureNoWebsite = function(data) {
    return Website.get().then((function(_this) {
      return function(website) {
        if (!website.exists) {
          return;
        }
        return _this.exists(website);
      };
    })(this));
  };

  Publisher.prototype.exists = function(website) {
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

  Publisher.prototype.success = function(opts) {
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

  return Publisher;

})();
