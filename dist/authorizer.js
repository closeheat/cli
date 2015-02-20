var Authorizer, Log, Promise, Urls, fs, homePath, inquirer, request;

fs = require('fs');

homePath = require('home-path');

inquirer = require('inquirer');

request = require('request');

Promise = require('bluebird');

Log = require('./log');

Urls = require('./urls');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.saveToken = function(access_token) {
    var config;
    config = {
      access_token: access_token
    };
    fs.writeFileSync(this.configFile(), JSON.stringify(config));
    return Log.doneLine('Access token saved.');
  };

  Authorizer.prototype.accessToken = function() {
    return JSON.parse(fs.readFileSync(this.configFile()).toString()).access_token;
  };

  Authorizer.prototype.configFile = function() {
    return "" + (homePath()) + "/.closeheat/config.json";
  };

  Authorizer.prototype.login = function(cb) {
    var login_questions;
    if (cb == null) {
      cb = function() {};
    }
    login_questions = [
      {
        message: 'Your email address',
        name: 'email',
        type: 'input'
      }, {
        message: 'Your password',
        name: 'password',
        type: 'password'
      }
    ];
    return inquirer.prompt(login_questions, (function(_this) {
      return function(answers) {
        return _this.getToken(answers).then(cb)["catch"](function(status) {
          if (status === 401) {
            Log.error("Wrong password or email. Please try again");
            return _this.login();
          } else {
            return Log.backendError();
          }
        });
      };
    })(this));
  };

  Authorizer.prototype.getToken = function(answers) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return request({
          url: Urls.getToken(),
          qs: answers,
          method: 'post',
          json: true
        }, function(err, resp) {
          if (resp.statusCode === 200) {
            _this.saveToken(resp.body.access_token);
            return resolve();
          } else {
            return reject(resp.statusCode);
          }
        });
      };
    })(this));
  };

  return Authorizer;

})();
