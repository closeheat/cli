var Authorizer, Log, fs, homePath;

fs = require('fs');

homePath = require('home-path');

Log = require('./log');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.login = function(access_token) {
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

  return Authorizer;

})();
