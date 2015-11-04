var Authorized, Cloner, Git, Log, Notifier, Promise, Urls;

Promise = require('bluebird');

Git = require('./git');

Authorized = require('./authorized');

Urls = require('./urls');

Log = require('./log');

Notifier = require('./notifier');

module.exports = Cloner = (function() {
  function Cloner() {}

  Cloner.prototype.clone = function(slug) {
    Log.logo();
    Log.spin("Getting website information for " + slug + ".");
    return this.getAppData(slug).then((function(_this) {
      return function(app) {
        Log.stop();
        Log.br();
        Log.spin("Cloning GitHub repository from " + app.github_repo + ".");
        return _this.execCloning(app.github_repo, app.default_branch, slug).then(function() {
          Notifier.notify('app_clone', app.slug);
          Log.stop();
          Log.inner("Cloned the app code to directory '" + slug + "'.");
          Log.br();
          Log.p('The quickest way to deploy changes to closeheat.com and GitHub is with:');
          Log.secondaryCode('closeheat deploy');
          Log.br();
          Log.p('For more awesome tricks type:');
          return Log.secondaryCode('closeheat help');
        });
      };
    })(this))["catch"](function(err) {
      return Log.error(err);
    });
  };

  Cloner.prototype.getAppData = function(slug) {
    return new Promise(function(resolve, reject) {
      return Authorized.post(Urls.findApp(), {
        slug: slug
      }).then(function(resp) {
        if (!resp.app.exists) {
          return Log.error("Website named '" + slug + "' does not exist.");
        }
        return resolve(resp.app);
      });
    });
  };

  Cloner.prototype.execCloning = function(github_repo, branch, slug) {
    this.git = new Git();
    return new Promise(function(resolve, reject) {
      return new Git().exec('clone', ["git@github.com:" + github_repo + ".git", slug], function(err, resp) {
        if (err) {
          return reject(err);
        }
        return resolve();
      });
    });
  };

  return Cloner;

})();
