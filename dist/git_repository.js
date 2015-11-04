var Git, GitRepository, Promise, _;

Promise = require('bluebird');

_ = require('lodash');

Git = require('git-wrapper');

module.exports = GitRepository = (function() {
  var GITHUB_REPO_REGEX;

  function GitRepository() {}

  GitRepository.ensureRemote = function(opts) {
    return GitRepository.exists().then(function(github_repo) {
      if (github_repo.exists) {
        return _.assign(opts, {
          remote: github_repo.name
        });
      }
      return GitRepository.addOriginRemote(opts.github_repo_url).then(function() {
        return _.assign(opts, {
          remote: opts.github_repo_url
        });
      });
    });
  };

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
          var repo_match;
          if (err) {
            return reject(err);
          }
          repo_match = resp.match(GITHUB_REPO_REGEX);
          if (!repo_match) {
            return resolve({
              exists: false
            });
          }
          return resolve({
            exists: true,
            name: repo_match[1]
          });
        });
      };
    })(this));
  };

  return GitRepository;

})();
