var Config, fs, homePath, path, pkg;

homePath = require('home-path');

path = require('path');

pkg = require('../package.json');

fs = require('fs');

module.exports = Config = (function() {
  function Config() {}

  Config.file = function() {
    return path.join(this.dir(), 'config.json');
  };

  Config.fileContents = function() {
    return JSON.parse(fs.readFileSync(this.file()).toString());
  };

  Config.dir = function() {
    var result;
    result = path.join(homePath(), '.closeheat');
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
