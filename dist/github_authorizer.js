var GitHubAuthorizer, Urls, open;

open = require('open');

Urls = require('./urls');

module.exports = GitHubAuthorizer = (function() {
  function GitHubAuthorizer() {}

  GitHubAuthorizer.prototype.open = function() {
    var Log;
    Log = require('./log');
    Log.doneLine("Authorize GitHub at " + (Urls.authorizeGitHub()) + " in your browser.");
    if (!process.env.CLOSEHEAT_TEST) {
      return open(Urls.authorizeGitHub());
    }
  };

  return GitHubAuthorizer;

})();
