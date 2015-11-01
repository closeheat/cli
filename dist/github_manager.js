var Git, GitHubManager, GitRepository, Log, Promise, SlugManager, Urls, User, UserInput, _, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

inquirer = require('inquirer');

_ = require('lodash');

Urls = require('./urls');

SlugManager = require('./slug_manager');

Log = require('./log');

UserInput = require('./user_input');

User = require('./user');

Git = require('./git');

GitRepository = require('./git_repository');

module.exports = GitHubManager = (function() {
  function GitHubManager() {}

  GitHubManager.choose = function(opts) {
    var get_it;
    get_it = GitRepository.exists().then(function(repo) {
      if (repo.exists) {
        return GitHubManager.reuse(repo.name, opts.slug);
      }
      return GitHubManager["new"](opts.slug);
    });
    return get_it.then(function(name) {
      return _.assign(opts, {
        repo: name
      });
    });
  };

  GitHubManager["new"] = function(slug) {
    return User.get().then(function(user) {
      return UserInput.repo(user.name + "/" + slug);
    });
  };

  GitHubManager.reuse = function(repo_name, slug) {
    return UserInput.reuseRepo(repo_name).then((function(_this) {
      return function(reuse) {
        if (!reuse) {
          return _this["new"](slug);
        }
        return repo_name;
      };
    })(this));
  };

  GitHubManager.create = function(repo_name) {
    return new Promise(function(resolve, reject) {
      return resolve();
    });
  };

  return GitHubManager;

})();
