var Bundler, Color, Log, browserify, buffer, fs, gulp, gulpFilter, gutil, path, q, source, sourcemaps, through, _;

fs = require('fs');

q = require('bluebird');

_ = require('lodash');

path = require('path');

gulpFilter = require('gulp-filter');

through = require('through2');

browserify = require('browserify');

source = require('vinyl-source-stream');

buffer = require('vinyl-buffer');

sourcemaps = require('gulp-sourcemaps');

gulp = require('gulp');

gutil = require('gutil');

Log = require('./log');

Color = require('./color');

module.exports = Bundler = (function() {
  function Bundler(dist_app) {
    this.dist_app = dist_app;
  }

  Bundler.prototype.bundle = function() {
    console.log('bndling');
    return gulp.src(path.join(this.dist_app, '**/*.js')).pipe(this.minFilter()).pipe(this.exec().on('error', gutil.log)).on('end', function() {
      return console.log('scanned');
    });
  };

  Bundler.prototype.minFilter = function() {
    return gulpFilter(function(file) {
      return !/.min./.test(file.path);
    });
  };

  Bundler.prototype.finishedBundling = function() {
    return console.log('Finighe bundle');
  };

  Bundler.prototype.exec = function() {
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

  return Bundler;

})();
