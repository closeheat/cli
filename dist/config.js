var Config, fs, homePath, path, pkg;

homePath = require('home-path');

path = require('path');

pkg = require('../package.json');

fs = require('fs');

module.exports = Config = (function() {
  function Config() {}

  Config.file = function() {
    var config_path;
    config_path = path.join(this.dir(), 'config.json');
    if (!fs.existsSync(config_path)) {
      fs.writeFileSync(config_path, JSON.stringify({
        access_token: 'none'
      }));
    }
    return config_path;
  };

  Config.fileContents = function() {
    return JSON.parse(fs.readFileSync(this.file()).toString());
  };

  Config.dir = function() {
    var result;
    result = global.CONFIG_DIR;
    if (!fs.existsSync(result)) {
      fs.mkdirSync(result);
    }
    return result;
  };

  Config.version = function() {
    return pkg.version;
  };

  Config.update = function(key, val) {
    var contents;
    contents = this.fileContents();
    contents[key] = val;
    return fs.writeFileSync(this.file(), JSON.stringify(contents));
  };

  return Config;

})();
