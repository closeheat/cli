var Authorizer, Color, Config, Log, Promise, Urls, fs, inquirer, pkg, request;

fs = require('fs');

inquirer = require('inquirer');

request = require('request');

pkg = require('../package.json');

Promise = require('bluebird');

Log = require('./log');

Urls = require('./urls');

Color = require('./color');

Config = require('./config');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.saveToken = function(access_token) {
    var config;
    config = {
      access_token: access_token
    };
    Config.update('access_token', access_token);
    Log = require('./log');
    return Log.doneLine('Access token saved.');
  };

  Authorizer.prototype.accessToken = function() {
    return Config.fileContents().access_token;
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
            Log = require('./log');
            if (resp.status === 'locked') {
              Log.error('Too many invalid logins. Account locked for 1 hour.', false);
              return Log.innerError("Check your email for unlock instructions or contact the support at " + (Color.violet('closeheat.com/support')) + ".");
            } else {
              Log.error("Wrong password or email. Please try again", false, '', 'login');
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
        var params;
        params = {
          url: Urls.getToken(),
          headers: {
            'X-CLI-Version': pkg.version
          },
          qs: answers,
          method: 'post',
          json: true
        };
        return request(params, function(err, resp) {
          if (err) {
            Log.error(err);
          }
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
    Log = require('./log');
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

  return Authorizer;

})();
