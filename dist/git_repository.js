var Git, GitRepository, Promise, _;

Promise = require('bluebird');

_ = require('lodash');

Git = require('git-wrapper');

module.exports = GitRepository = (function() {
  function GitRepository() {}

  GitRepository.ensure = function(opts) {
    return GitRepository.exists().then(function(resp) {
      if (resp.exists) {
        return _.assign(opts, {
          repository: true
        });
      }
      return GitRepository.init().then(function() {
        return _.assign(opts, {
          repository: true
        });
      });
    });
  };

  GitRepository.init = function(url) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('init', function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve(resp);
        });
      };
    })(this));
  };

  GitRepository.exists = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return new Git().exec('remote', ['--verbose'], function(err, resp) {
          if (err) {
            if (err.message.match(/Not a git repository/)) {
              return resolve({
                exists: false
              });
            } else {
              return resolve({
                exists: true
              });
            }
          }
        });
      };
    })(this));
  };

  return GitRepository;

})();
