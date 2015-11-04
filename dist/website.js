var Authorized, Color, GitHubManager, GitRepository, Log, Promise, SlugManager, Urls, Website, _, inquirer, path;

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

GitRepository = require('./git_repository');

_ = require('lodash');

module.exports = Website = (function() {
  function Website() {}

  Website.create = function(opts) {
    return Website.execRequest(opts.slug, opts.repo).then(function(resp) {
      return _.assign(opts, {
        website: resp.url,
        github_repo_url: resp.github_repo_url
      });
    });
  };

  Website.handleProblem = function(resp, opts) {
    if (resp.error_type === 'slug-exists') {
      Log.p("Subdomain " + opts.slug + " is already taken. Could you choose another one?");
      return _.assign(opts, {
        slug: null
      });
    } else {
      Log.p("Some error happened: " + (JSON.stringify(resp)));
      return process.exit();
    }
  };

  Website.get = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return GitRepository.exists().then(function(repo) {
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
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.post(Urls.publish(), {
          repo: repo,
          slug: slug
        }).then(function(resp) {
          return resolve(resp.app);
        });
      };
    })(this));
  };

  return Website;

})();
