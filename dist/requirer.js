var Requirer, acorn, callback, coffee, fs, gulp, gutil, npmi, path, through, util, _,
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

module.exports = Requirer = (function() {
  function Requirer(dist, dist_app) {
    this.dist = dist;
    this.dist_app = dist_app;
    this.downloadModules = __bind(this.downloadModules, this);
    this.modules = [];
  }

  Requirer.prototype.scan = function() {
    return gulp.src(path.join(this.dist_app, '**/*.js')).pipe(this.scanner().on('error', gutil.log));
  };

  Requirer.prototype.downloader = function(arg) {
    console.log('down');
    return console.log(arg);
  };

  Requirer.prototype.registerModule = function(module_name) {
    return this.modules.push(module_name);
  };

  Requirer.prototype.downloadModules = function() {
    var package_file;
    package_file = {
      name: 'closeheat-app',
      version: '1.0.0',
      dependencies: {},
      path: '.'
    };
    _.each(_.uniq(this.modules), (function(_this) {
      return function(module) {
        package_file.dependencies[module] = '';
        return npmi({
          name: module,
          path: _this.dist
        }, function(err, result) {
          if (result) {
            return util.puts("" + module + " installed");
          }
        });
      };
    })(this));
    return fs.writeFileSync(path.join(this.dist, 'package.json'), JSON.stringify(package_file));
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
