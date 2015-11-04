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
          message: 'What subdomain would you like? [example: HELLO.closeheatapp.com]',
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
          return resolve(answer.repo);
        });
      };
    })(this));
  };

  return UserInput;

})();
