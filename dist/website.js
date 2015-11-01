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
      return GitRepository.addOriginRemote(resp.repo_url).then(function() {
        return _.assign(opts, {
          website: resp.url
        });
      });
    })["catch"](function(resp) {
      if (resp.error === 'app-exists') {
        return _.assign(opts, {
          slug: null
        });
      }
    });
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
        return Authorized.post(Urls.websiteExists(), {
          repo: repo
        }).then(function(resp) {
          return resolve({
            exists: resp.exists,
            repo: repo,
            slug: resp.slug
          });
        });
      };
    })(this));
  };

  Website.execRequest = function(slug, repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.post(Urls.publishNewWebsite(), {
          repo: repo,
          slug: slug
        }).then(function(resp) {
          return resolve({
            url: resp.url,
            repo_url: resp.repo_url
          });
        });
      };
    })(this));
  };

  return Website;

})();
