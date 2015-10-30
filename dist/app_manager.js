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
    return AppManager.execRequest(slug, repo);
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
          if (resp.body.success) {
            return resolve(opts);
          } else {
            return reject({
              slug: slug,
              repo: repo,
              error: 'app-exists'
            });
          }
        });
      };
    })(this));
  };

  return AppManager;

})();
