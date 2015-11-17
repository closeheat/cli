var Authorized, Color, GitHubManager, GitRemote, Log, Promise, SlugManager, Urls, Website, _, inquirer, path;

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

module.exports = Website = (function() {
  function Website() {}

  Website.create = function(opts) {
    return Website.execRequest(opts.slug, opts.repo).then(function(resp) {
      return _.assign(opts, {
        website: resp.app.url,
        github_repo_url: resp.app.github_repo_url
      });
    })["catch"](function(e) {
      return Website.handleProblem(e.message, opts);
    });
  };

  Website.handleProblem = function(message, opts) {
    if (message === 'slug-exists') {
      Log.p("Subdomain " + opts.slug + " is already taken. Could you choose another one?");
      return _.assign(opts, {
        slug: null
      });
    } else {
      Log.p("Some error happened. Shoot a message to support@closeheat.com.");
      return process.exit();
    }
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
