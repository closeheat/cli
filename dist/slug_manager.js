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
    return SlugManager.suggest().then(UserInput.slug).then(function(slug) {
      return _.assign(opts, {
        slug: slug
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

  return SlugManager;

})();
