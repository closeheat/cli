var Log, Promise, SlugManager, Urls, UserInput, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

inquirer = require('inquirer');

Urls = require('./urls');

UserInput = require('./user_input');

Log = require('./log');

module.exports = SlugManager = (function() {
  function SlugManager() {}

  SlugManager.choose = function() {
    return this.suggest().then(UserInput.slug).then(this.isFree)["catch"](this.rechooseSlug);
  };

  SlugManager.suggest = function() {
    var default_app_name;
    default_app_name = path.basename(process.cwd());
    return new Promise(function(resolve, reject) {
      return resolve(default_app_name);
    });
  };

  SlugManager.folder = function() {
    return _.last(process.cwd().split('/'));
  };

  SlugManager.rechooseSlug = function() {
    Log.p('This slug is used');
    return this.choose();
  };

  SlugManager.isFree = function(slug) {
    return new Promise(function(resolve, reject) {
      return resolve(slug);
    });
  };

  return SlugManager;

})();
