var Git, GitHubManager, Log, Promise, ReuseRepoContinuousDeployment, SlugManager, Urls, UserInput, _, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

inquirer = require('inquirer');

_ = require('lodash');

Urls = require('./urls');

SlugManager = require('./slug_manager');

Log = require('./log');

UserInput = require('./user_input');

Git = require('./git');

ReuseRepoContinuousDeployment = require('./reuse_repo_continuous_deployment');

module.exports = GitHubManager = (function() {
  var GITHUB_REPO_REGEX;

  function GitHubManager() {}

  GitHubManager.repo = function(slug) {
    return GitHubManager.noRepo(slug).then(GitHubManager.newRepo)["catch"](GitHubManager.reuse);
  };

  GitHubManager.newRepo = UserInput.repo;

  GitHubManager.reuse = function(err) {
    return ReuseRepoContinuousDeployment.start(err.repo, err.slug)["catch"](function() {
      return GitHubManager.newRepo(err.slug);
    });
  };

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/;

  GitHubManager.noRepo = function(slug) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('remote', ['--verbose'], function(err, resp) {
          var existing_repo;
          if (err) {
            return reject(err);
          }
          existing_repo = resp.match(GITHUB_REPO_REGEX)[1];
          if (existing_repo) {
            return reject({
              repo: existing_repo,
              slug: slug
            });
          }
          return resolve(slug);
        });
      };
    })(this));
  };

  return GitHubManager;

})();
