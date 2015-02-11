var Authorizer, fs, homePath;

fs = require('fs');

homePath = require('home-path');

module.exports = Authorizer = (function() {
  function Authorizer() {}

  Authorizer.prototype.login = function(access_token) {
    var config, config_file;
    config_file = "" + (homePath()) + "/.closeheat/config.json";
    config = {
      access_token: access_token
    };
    fs.writeFileSync(config_file, JSON.stringify(config));
    return console.log("Access token saved.");
  };

  return Authorizer;

})();
