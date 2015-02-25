var Authorizer, Color, Log, Promise, Urls, fs, homePath, inquirer, path, request;

fs = require('fs');

homePath = require('home-path');

inquirer = require('inquirer');

request = require('request');

Promise = require('bluebird');

path = require('path');

Log = require('./log');

Urls = require('./urls');

Color = require('./color');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.saveToken = function(access_token) {
    var config;
    config = {
      access_token: access_token
    };
    if (!fs.existsSync(this.configDir())) {
      fs.mkdirSync(this.configDir());
    }
    fs.writeFileSync(this.configFile(), JSON.stringify(config));
    return Log.doneLine('Access token saved.');
  };

  Authorizer.prototype.accessToken = function() {
    return JSON.parse(fs.readFileSync(this.configFile()).toString()).access_token;
  };

  Authorizer.prototype.configFile = function() {
    return path.join(this.configDir(), 'config.json');
  };

  Authorizer.prototype.configDir = function() {
    return path.join(homePath(), '.closeheat');
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
        return _this.getToken(answers).then(function() {
          Log.br();
          return cb();
        })["catch"](function(resp) {
          if (resp.code === 401) {
            if (resp.status === 'locked') {
              Log.error('Too many invalid logins. Account locked for 1 hour.', false);
              return Log.innerError("Check your email for unlock instructions or contact the support at " + (Color.violet('closeheat.com/support')) + ".");
            } else {
              Log.error("Wrong password or email. Please try again", false);
              return _this.login(cb);
            }
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
            return reject({
              code: resp.statusCode,
              status: resp.body.status
            });
          }
        });
      };
    })(this));
  };

  Authorizer.prototype.forceLogin = function(cb) {
    Log.stop();
    Log.br();
    Log.p(Color.redYellow('Please login to closeheat.com to check out your app list.'));
    return this.login(cb);
  };

  Authorizer.prototype.unauthorized = function(resp) {
    return resp.statusCode === 401;
  };

  Authorizer.prototype.checkLoggedIn = function(resp, cb) {
    if (this.unauthorized(resp)) {
      return this.forceLogin(cb);
    }
  };

  Authorizer.prototype.onlyLoggedIn = function(resp) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (_this.unauthorized(resp)) {
          return _this.forceLogin(resolve);
        } else {
          return resolve();
        }
      };
    })(this));
  };

  return Authorizer;

})();
