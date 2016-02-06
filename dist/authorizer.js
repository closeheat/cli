var Authorized, Authorizer, Config, Urls, open;

open = require('open');

Urls = require('./urls');

Config = require('./config');

Authorized = require('./authorized');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.saveToken = function(access_token) {
    var Log, config, overriden;
    overriden = this.accessToken();
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

  Authorizer.prototype.login = function(token) {
    if (token) {
      return this.saveToken(token);
    }
    if (this.accessToken()) {
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
    if (!process.env.CLOSEHEAT_TEST) {
      return open(Urls.loginInstructions());
    }
  };

  return Authorizer;

})();
