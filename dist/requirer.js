var Bundler, Color, Log, NpmDownloader, RequireScanner, Requirer, callback, coffee, fs, gulp, gutil, htmlparser, npmi, path, through, util, _;

fs = require('fs');

through = require('through2');

path = require('path');

gulp = require('gulp');

gutil = require('gutil');

util = require('util');

coffee = require('gulp-coffee');

_ = require('lodash');

callback = require('gulp-callback');

npmi = require('npmi');

htmlparser = require("htmlparser2");

Log = require('./log');

Color = require('./color');

NpmDownloader = require('./npm_downloader');

Bundler = require('./bundler');

RequireScanner = require('./require_scanner');

module.exports = Requirer = (function() {
  function Requirer(dist, dist_app) {
    this.dist = dist;
    this.dist_app = dist_app;
    this.bundler = new Bundler(this.dist_app);
    this.require_scanner = new RequireScanner(this.dist_app);
  }

  Requirer.prototype.install = function() {
    return this.require_scanner.getRequires().then((function(_this) {
      return function(modules) {
        return new NpmDownloader(_this.dist, modules).downloadAll().then(function() {
          console.log("bund");
          return _this.bundler.bundle();
        });
      };
    })(this));
  };

  return Requirer;

})();
