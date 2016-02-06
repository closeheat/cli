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
          Log.br();
          Log.p("This folder is not in a GitHub repository.");
          Log.p("Set up GitHub repository first: https://github.com/new");
          return process.exit();
        }
      };
    })(this));
  };

  return GitHubManager;

})();
