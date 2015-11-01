var Git, GitRepository, Log, Promise, ReuseRepoContinuousDeployment, SlugManager, Urls, UserInput, _, inquirer, path;

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

module.exports = GitRepository = (function() {
  var GITHUB_REPO_REGEX;

  function GitRepository() {}

  GitRepository.addOriginRemote = function(url) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('remote', ["add origin " + url], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp);
        });
      };
    })(this));
  };

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/;

  GitRepository.exists = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('remote', ['--verbose'], function(err, resp) {
          var existing_repo;
          if (err) {
            return reject(err);
          }
          existing_repo = resp.match(GITHUB_REPO_REGEX)[1];
          return resolve({
            exists: !!existing_repo,
            name: existing_repo
          });
        });
      };
    })(this));
  };

  return GitRepository;

})();
