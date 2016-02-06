var Authorized, Promise, SlugManager, Urls, UserInput, _;

Promise = require('bluebird');

_ = require('lodash');

Urls = require('./urls');

UserInput = require('./user_input');

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
