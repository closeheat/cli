var Authorizer, Color, Config, Promise, Urls, fs, inquirer, open, pkg, request;

fs = require('fs');

inquirer = require('inquirer');

request = require('request');

pkg = require('../package.json');

Promise = require('bluebird');

open = require('open');

Urls = require('./urls');

Color = require('./color');

Config = require('./config');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.saveToken = function(access_token) {
    var Log, config, overriden;
    overriden = this.accessTokenExists();
    config = {
      access_token: access_token
    };
    Config.update('access_token', access_token);
    Log = require('./log');
    if (overriden) {
      return Log.doneLine('Login successful. New access token saved.');
    } else {
      return Log.doneLine('Login successful. Access token saved.');
    }
  };

  Authorizer.prototype.accessToken = function() {
    return Config.fileContents().access_token;
  };

  Authorizer.prototype.accessTokenExists = function() {
    return Config.fileContents().access_token && Config.fileContents().access_token !== 'none';
  };

  Authorizer.prototype.login = function(token) {
    if (token) {
      return this.saveToken(token);
    }
    if (this.accessTokenExists()) {
      return this.youreLoggedIn();
    } else {
      return this.openLogin();
    }
  };

  Authorizer.prototype.youreLoggedIn = function() {
    var Log;
    Log = require('./log');
    Log.doneLine('You are already logged in.');
    return Log.inner("Log in with another account here: " + (Urls.loginInstructions()));
  };

  Authorizer.prototype.openLogin = function() {
    var Log;
    Log = require('./log');
    Log.doneLine("Log in at " + (Urls.loginInstructions()) + " in your browser.");
    if (global.BROWSER) {
      return open(Urls.loginInstructions());
    }
  };

  Authorizer.prototype.forceLogin = function(cb) {
    var Log;
    Log = require('./log');
    Log.stop();
    Log.br();
    return Log.p(Color.redYellow('Please login to closeheat.com to check out your app list.'));
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
