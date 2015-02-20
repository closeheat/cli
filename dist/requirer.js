var Bundler, NpmDownloader, RequireScanner, Requirer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

NpmDownloader = require('./npm_downloader');

Bundler = require('./bundler');

RequireScanner = require('./require_scanner');

module.exports = Requirer = (function() {
  function Requirer(dist, dist_app) {
    this.dist = dist;
    this.dist_app = dist_app;
    this.install = __bind(this.install, this);
    this.bundler = new Bundler(this.dist_app);
    this.require_scanner = new RequireScanner(this.dist_app);
  }

  Requirer.prototype.install = function() {
    return this.require_scanner.getRequires().then((function(_this) {
      return function(modules) {
        return new NpmDownloader(_this.dist, modules).downloadAll().then(function() {
          return _this.bundler.bundle();
        });
      };
    })(this));
  };

  return Requirer;

})();
