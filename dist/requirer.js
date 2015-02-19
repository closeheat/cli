var NPM, Requirer, acorn, browserify, buffer, callback, coffee, fs, gulp, gulpFilter, gutil, htmlparser, npmi, path, source, sourcemaps, through, util, _,
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

NPM = require('machinepack-npm');

module.exports = Requirer = (function() {
  function Requirer(dist, dist_app) {
    this.dist = dist;
    this.dist_app = dist_app;
    this.downloadModules = __bind(this.downloadModules, this);
    this.modules = [];
  }

  Requirer.prototype.scan = function() {
    return gulp.src(path.join(this.dist_app, '**/*.js')).pipe(this.scanner().on('error', gutil.log)).on('end', function() {
      return console.log('scanned');
    });
  };

  Requirer.prototype.registerModule = function(module_name) {
    return this.modules.push(module_name);
  };

  Requirer.prototype.downloadModules = function() {
    var count, package_file, total;
    package_file = {
      name: 'closeheat-app',
      version: '1.0.0',
      dependencies: {},
      path: '.'
    };
    total = this.modulesToDownload().length;
    if (total === 0) {
      this.continueBundling();
    }
    count = 0;
    _.each(this.modulesToDownload(), (function(_this) {
      return function(module) {
        return NPM.installPackage({
          name: module,
          loglevel: 'silent',
          prefix: _this.dist
        }).exec({
          error: function(err) {
            console.log('eeeerrr');
            return console.log(err);
          },
          success: function(name) {
            count += 1;
            if (count === total) {
              _this.continueBundling();
            }
            console.log('succee');
            return console.log(name);
          }
        });
      };
    })(this));
    return fs.writeFileSync(path.join(this.dist, 'package.json'), JSON.stringify(package_file));
  };

  Requirer.prototype.continueBundling = function() {
    var min_filter;
    console.log('cont');
    min_filter = gulpFilter(function(file) {
      return !/.min./.test(file.path);
    });
    return gulp.src(path.join(this.dist_app, '**/*.js')).pipe(min_filter).pipe(this.bundler().on('error', gutil.log)).on('end', function() {
      return console.log('scanned');
    });
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

  Requirer.prototype.modulesToDownload = function() {
    return _.reject(_.uniq(this.modules), (function(_this) {
      return function(module) {
        return fs.existsSync(path.join(_this.dist, 'node_modules', module));
      };
    })(this));
  };

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
          return _this.registerModule(module_name);
        }), walkall.traversers);
        return cb();
      };
    })(this), this.downloadModules);
  };

  return Requirer;

})();
