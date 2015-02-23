var Dirs, Promise, fs, homePath, mkdirp, path;

path = require('path');

homePath = require('home-path');

fs = require('fs.extra');

Promise = require('bluebird');

mkdirp = require('mkdirp');

module.exports = Dirs = (function() {
  function Dirs(settings) {
    var tmp_token;
    if (settings == null) {
      settings = {};
    }
    this.target = path.join(settings.dist || process.cwd(), settings.name);
    tmp_token = '353cleaned5sometime';
    this.tmp = settings.tmp || ("" + (homePath()) + "/.closeheat/tmp/creations/" + tmp_token + "/");
    this.parts = path.join(this.tmp, 'parts');
    this.whole = path.join(this.tmp, 'whole');
    this.transformed = path.join(this.tmp, 'transformed');
    this.src = settings.src;
    this.dist = settings.dist;
  }

  Dirs.prototype.clean = function() {
    if (fs.existsSync(this.tmp)) {
      return fs.rmrfSync(this.tmp);
    }
  };

  Dirs.prototype.create = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return mkdirp(_this.parts, function(parts_error) {
          return mkdirp(_this.whole, function(whole_error) {
            return mkdirp(_this.transformed, function(transformed_error) {
              if (parts_error) {
                return reject(parts_error);
              }
              if (whole_error) {
                return reject(whole_error);
              }
              if (transformed_error) {
                return reject(transformed_error);
              }
              return resolve();
            });
          });
        });
      };
    })(this));
  };

  return Dirs;

})();
