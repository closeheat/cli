var Dirs, Q, fs, homePath, mkdirp, path;

path = require('path');

homePath = require('home-path');

fs = require('fs.extra');

Q = require('q');

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
  }

  Dirs.prototype.clean = function() {
    if (fs.existsSync(this.tmp)) {
      return fs.rmrfSync(this.tmp);
    }
  };

  Dirs.prototype.create = function() {
    var deferred;
    deferred = Q.defer();
    mkdirp(this.parts, (function(_this) {
      return function(parts_error) {
        return mkdirp(_this.whole, function(whole_error) {
          return mkdirp(_this.transformed, function(transformed_error) {
            if (parts_error) {
              console.log;
            }
            if (whole_error) {
              console.log;
            }
            if (transformed_error) {
              console.log;
            }
            return deferred.resolve();
          });
        });
      };
    })(this));
    return deferred.promise;
  };

  return Dirs;

})();
