var Authorized, Log, Promise, Urls, UserInput, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

Urls = require('./urls');

Authorized = require('./authorized');

Log = require('./log');

module.exports = UserInput = (function() {
  function UserInput() {}

  UserInput.slug = function(suggested) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return inquirer.prompt({
          message: 'What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later)',
          name: 'slug',
          "default": suggested
        }, function(answer) {
          return resolve(answer.slug);
        });
      };
    })(this));
  };

  UserInput.repo = function(suggested) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return inquirer.prompt({
          message: "How will you name a new GitHub repository? (example: " + suggested + ")",
          name: 'repo'
        }, function(answer) {
          return resolve(answer.repo.replace(' ', ''));
        });
      };
    })(this));
  };

  UserInput.reuseRepo = function(repo_name) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return inquirer.prompt({
          message: "Would you like to use your existing " + repo_name + " GitHub repository repo for continuos delivery?",
          type: 'confirm',
          name: 'reuse'
        }, function(answer) {
          return resolve(answer.reuse);
        });
      };
    })(this));
  };

  return UserInput;

})();
