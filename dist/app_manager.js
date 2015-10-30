var AppManager, Authorized, Color, Log, Promise, SlugManager, Urls, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

inquirer = require('inquirer');

Urls = require('./urls');

SlugManager = require('./slug_manager');

Log = require('./log');

Authorized = require('./authorized');

Color = require('./color');

module.exports = AppManager = (function() {
  function AppManager() {}

  AppManager.create = function(slug, repo) {
    return AppManager.execRequest(slug, repo).then(AppManager.showSuccess);
  };

  AppManager.showSuccess = function(opts) {
    var repo, slug;
    slug = opts.slug;
    repo = opts.repo;
    Log.p('Success!');
    Log.p("Your website " + (Color.violet(slug + ".closeheatapp.com")) + " is now published.");
    Log.br();
    Log.p("GitHub repository " + repo + " is setup for continuous deployment.");
    Log.p("Every change to master branch will be immediately published.");
    Log.br();
    Log.p("The logs of each deploy are available with " + (Color.violet('closeheat log')) + ".");
    Log.p("It's useful to have them right after your " + (Color.violet('git push')) + " with " + (Color.violet('git push origin master && closeheat log')));
    Log.br();
    Log.p("To set up a custom domain or change a public directory type:");
    return Log.code('closeheat settings');
  };

  AppManager.execRequest = function(slug, repo) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.publishNewWebsite(),
          qs: {
            repo: repo,
            slug: slug
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          return reject({
            slug: '123',
            repo: '3312'
          });
          return resolve({
            slug: slug,
            repo: repo
          });
          if (resp.body.success) {
            return resolve(opts);
          } else {
            return reject({
              type: resp.body.error_type
            });
          }
        });
      };
    })(this));
  };

  return AppManager;

})();
