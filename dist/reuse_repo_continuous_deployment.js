var Authorized, Authorizer, Color, DeployLog, Git, Initializer, Log, Notifier, Promise, ReuseRepoContinuousDeployment, Urls, UserInput, _, fs, inquirer, open;

Promise = require('bluebird');

inquirer = require('inquirer');

_ = require('lodash');

open = require('open');

fs = require('fs.extra');

Git = require('./git');

Initializer = require('./initializer');

Authorized = require('./authorized');

Authorizer = require('./authorizer');

Urls = require('./urls');

DeployLog = require('./deploy_log');

Log = require('./log');

Color = require('./color');

Notifier = require('./notifier');

UserInput = require('./user_input');

module.exports = ReuseRepoContinuousDeployment = (function() {
  function ReuseRepoContinuousDeployment() {}

  ReuseRepoContinuousDeployment.start = function(existing_repo, slug) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return UserInput.reuseRepo(existing_repo).then(function(reuse) {
          if (!reuse) {
            return reject({
              slug: slug
            });
          }
          return resolve(existing_repo);
        });
      };
    })(this));
  };

  return ReuseRepoContinuousDeployment;

})();
