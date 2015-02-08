var Requirer, acorn, callback, coffee, fs, gulp, gutil, npmi, path, through, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

fs = require('fs');

through = require('through2');

path = require('path');

gulp = require('gulp');

gutil = require('gutil');

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
    console.log('Scanning');
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
      dependencies: {}
    };
    _.each(_.uniq(this.modules), function(module) {
      return package_file.dependencies[module] = '*';
    });
    fs.writeFile(path.join(this.dist, 'package.json'), JSON.stringify(package_file));
    return npmi({
      path: this.dist
    }, function(err, result) {
      return console.log('installed');
    });
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
