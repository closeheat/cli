var Authorized, Color, GitHubManager, GitRemote, Log, Promise, Pusher, SlugManager, Urls, Website, _, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

inquirer = require('inquirer');

Urls = require('./urls');

SlugManager = require('./slug_manager');

Log = require('./log');

Authorized = require('./authorized');

Color = require('./color');

GitHubManager = require('./github_manager');

GitRemote = require('./git_remote');

_ = require('lodash');

Pusher = require('pusher-client');

module.exports = Website = (function() {
  function Website() {}

  Website.create = function(opts) {
    return Website.execRequest(opts.slug, opts.repo).then(function(resp) {
      Log.p("Setting up your website...");
      return Website.waitForBuild(resp.pusher).then(function() {
        Log.br();
        return _.assign(opts, {
          website: resp.app.url,
          github_repo_url: resp.app.github_repo_url
        });
      });
    })["catch"](function(e) {
      return Website.handleProblem(e.message, opts);
    });
  };

  Website.waitForBuild = function(pusher_data) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var pusher, pusher_user_channel;
        pusher = new Pusher(pusher_data.key, {
          authEndpoint: pusher_data.auth_endpoint,
          auth: {
            params: {
              api_token: Authorized.token()
            }
          }
        });
        pusher_user_channel = pusher.subscribe(pusher_data.user_key);
        return pusher_user_channel.bind('app.build', function() {
          return resolve();
        });
      };
    })(this));
  };

  Website.handleProblem = function(message, opts) {
    var SLUG_ERRORS, graceful_error;
    SLUG_ERRORS = {
      'slug-exists': 'Subdomain is already taken. I know how it feels...',
      'slug-too-short': 'Subdomain is too short (min. 3 characters). But pretty!',
      'slug-invalid': 'Subdomain can only have letters, numbers and dashes.'
    };
    graceful_error = SLUG_ERRORS[message];
    if (!graceful_error) {
      this.showUngracefulError();
    }
    Log.p(graceful_error);
    return _.assign(opts, {
      slug: null
    });
  };

  Website.showUngracefulError = function() {
    Log.p("Amazing error happened. Shoot a message to support@closeheat.com.");
    Log.p("Sorry, but we will sort it out!");
    return process.exit();
  };

  Website.get = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return GitRemote.exists().then(function(repo) {
          if (!repo.exists) {
            return resolve({
              exists: false
            });
          }
          return _this.backend(repo.name).then(resolve);
        });
      };
    })(this));
  };

  Website.backend = function(repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.post(Urls.findApp(), {
          repo: repo
        }).then(function(resp) {
          return resolve(resp.app);
        });
      };
    })(this));
  };

  Website.execRequest = function(slug, repo) {
    return Authorized.post(Urls.publish(), {
      github_repo: repo,
      slug: slug
    });
  };

  return Website;

})();
