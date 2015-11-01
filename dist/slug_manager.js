var Authorized, Log, Promise, SlugManager, Urls, UserInput, _, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

_ = require('lodash');

inquirer = require('inquirer');

Urls = require('./urls');

UserInput = require('./user_input');

Log = require('./log');

Authorized = require('./authorized');

module.exports = SlugManager = (function() {
  function SlugManager() {}

  SlugManager.choose = function(opts) {
    if (opts.slug) {
      return validated_slug;
    }
    return SlugManager.suggest().then(UserInput.slug).then(function(slug) {
      return SlugManager.isFree(slug).then(function(is_free) {
        if (!is_free) {
          return SlugManager.rechooseSlug(opts);
        }
        return _.assign(opts, {
          slug: slug
        });
      });
    });
  };

  SlugManager.suggest = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.post(Urls.suggestSlug(), {
          folder: _this.folder()
        }).then(function(resp) {
          return resolve(resp.slug);
        });
      };
    })(this));
  };

  SlugManager.folder = function() {
    return _.last(process.cwd().split('/'));
  };

  SlugManager.rechooseSlug = function(opts) {
    Log.p('This slug is used');
    return SlugManager.choose(opts);
  };

  SlugManager.isFree = function(slug) {
    return new Promise(function(resolve, reject) {
      return resolve(true);
    });
  };

  return SlugManager;

})();