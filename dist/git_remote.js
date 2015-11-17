var Git, GitRemote, Promise, _;

Promise = require('bluebird');

_ = require('lodash');

Git = require('git-wrapper');

module.exports = GitRemote = (function() {
  var GITHUB_REPO_REGEX;

  function GitRemote() {}

  GitRemote.ensure = function(opts) {
    return GitRemote.exists().then(function(github_repo) {
      if (github_repo.exists) {
        return _.assign(opts, {
          remote: github_repo.name
        });
      }
      return GitRemote.addOrigin(opts.github_repo_url).then(function() {
        return _.assign(opts, {
          remote: opts.github_repo_url
        });
      });
    });
  };

  GitRemote.addOrigin = function(url) {
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

  GitRemote.exists = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('remote', ['--verbose'], function(err, resp) {
          var repo_match;
          if (err) {
            if (err.message.match(/Not a git repository/)) {
              return resolve({
                exists: false
              });
            } else {
              return reject(err);
            }
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

  return GitRemote;

})();
