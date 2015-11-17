var GitHubManager, GitRemote, Log, User, UserInput, _;

_ = require('lodash');

Log = require('./log');

UserInput = require('./user_input');

User = require('./user');

GitRemote = require('./git_remote');

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
    return GitRemote.exists().then((function(_this) {
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
      return UserInput.repo(user.github_username + "/" + slug);
    });
  };

  return GitHubManager;

})();
