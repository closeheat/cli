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
          message: "How will you name a new GitHub repository? ..",
          name: 'repo',
          "default": suggested
        }, function(answer) {
          if (!answer.repo) {
            return resolve(suggested);
          }
          if (answer.repo.match(/(.*)\/(.*)/)) {
            return resolve(answer.repo);
          }
          Log.p('Could you provide the repository name in "name/repository" format?');
          return resolve();
        });
      };
    })(this));
  };

  return UserInput;

})();
