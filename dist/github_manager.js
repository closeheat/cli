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
    return GitHubManager.oldOrNewRepo(opts).then(function(name) {
      return _.assign(opts, {
        repo: name
      });
    });
  };

  GitHubManager.oldOrNewRepo = function(opts) {
    return GitRepository.exists().then((function(_this) {
      return function(repo) {
        if (repo.exists) {
          Log.p("Using your existing GitHub repository: " + repo.name);
          return repo.name;
        } else {
          return _this["new"](opts.slug);
        }
      };
    })(this));
  };

  GitHubManager["new"] = function(slug) {
    return User.get().then(function(user) {
      return UserInput.repo(user.name + "/" + slug);
    });
  };

  return GitHubManager;

})();
