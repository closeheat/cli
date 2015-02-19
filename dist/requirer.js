var Color, Log, NpmDownloader, Requirer, acorn, browserify, buffer, callback, coffee, fs, gulp, gulpFilter, gutil, htmlparser, npmi, path, source, sourcemaps, through, util, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

through = require('through2');

path = require('path');

gulp = require('gulp');

gutil = require('gutil');

util = require('util');

coffee = require('gulp-coffee');

acorn = require('acorn');

_ = require('lodash');

callback = require('gulp-callback');

npmi = require('npmi');

htmlparser = require("htmlparser2");

gulpFilter = require('gulp-filter');

browserify = require('browserify');

source = require('vinyl-source-stream');

buffer = require('vinyl-buffer');

sourcemaps = require('gulp-sourcemaps');

Log = require('./log');

Color = require('./color');

NpmDownloader = require('./npm_downloader');

module.exports = Requirer = (function() {
  function Requirer(dist, dist_app) {
    this.dist = dist;
    this.dist_app = dist_app;
    this.bundle = __bind(this.bundle, this);
    this.npm_downloader = new NpmDownloader(this.dist);
  }

  Requirer.prototype.scan = function() {
    return gulp.src(path.join(this.dist_app, '**/*.js')).pipe(this.scanner().on('error', gutil.log)).on('end', function() {
      return console.log('scanned');
    });
  };

  Requirer.prototype.bundle = function() {
    var min_filter;
    console.log('con');
    min_filter = gulpFilter(function(file) {
      return !/.min./.test(file.path);
    });
    gulp.src(path.join(this.dist_app, '**/*.js')).pipe(min_filter).pipe(this.bundler().on('error', gutil.log)).on('end', function() {
      return console.log('scanned');
    });
    return 'c';
  };

  Requirer.prototype.bundler = function() {
    return through.obj((function(_this) {
      return function(file, enc, cb) {
        var bundler, relative;
        if (file.isNull()) {
          cb(null, file);
          return;
        }
        relative = path.relative(_this.dist_app, file.path);
        bundler = browserify({
          entries: [file.path],
          debug: true,
          standalone: 'CloseheatStandaloneModule'
        });
        return bundler.bundle().pipe(source(relative)).pipe(buffer()).pipe(sourcemaps.init({
          loadMaps: true
        })).pipe(sourcemaps.write('./')).pipe(gulp.dest(_this.dist_app)).on('end', cb);
      };
    })(this), this.finishedBundling);
  };

  Requirer.prototype.finishedBundling = function() {};

  Requirer.prototype.scanner = function() {
    return through.obj((function(_this) {
      return function(file, enc, cb) {
        var ast, walk, walkall;
        if (file.isNull()) {
          cb(null, file);
          return;
        }
        ast = acorn.parse(file.contents.toString());
        walk = require('acorn/util/walk');
        walkall = require('walkall');
        walk.simple(ast, walkall.makeVisitors(function(node) {
          var module_name;
          if (node.type !== 'CallExpression') {
            return;
          }
          if (node.callee.name !== 'require') {
            return;
          }
          module_name = node["arguments"][0].value;
          if (!module_name.match(/^[a-zA-Z]/)) {
            return;
          }
          return _this.npm_downloader.register(module_name);
        }), walkall.traversers);
        return cb();
      };
    })(this), _.partial(this.npm_downloader.downloadAll, this.bundle));
  };

  return Requirer;

})();
