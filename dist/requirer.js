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
    this.handleAllEvents = __bind(this.handleAllEvents, this);
    this.bundler = new Bundler(this.dist_app);
    this.require_scanner = new RequireScanner(this.dist_app);
  }

  Requirer.prototype.on = function(event_name, cb) {
    this.events || (this.events = {});
    this.events[event_name] = cb;
    return this;
  };

  Requirer.prototype.emit = function(event_name, data) {
    var _base, _base1;
    this.events || (this.events = {});
    if (typeof (_base = this.events).all === "function") {
      _base.all(event_name, data);
    }
    if (typeof (_base1 = this.events)[event_name] === "function") {
      _base1[event_name](data);
    }
    return this;
  };

  Requirer.prototype.handleAllEvents = function(event_name, data) {
    return this.emit(event_name, data);
  };

  Requirer.prototype.install = function() {
    return this.require_scanner.getRequires().then((function(_this) {
      return function(modules) {
        return new NpmDownloader(_this.dist, modules).on('all', _this.handleAllEvents).downloadAll().then(function() {
          return _this.bundler.bundle();
        });
      };
    })(this));
  };

  return Requirer;

})();
