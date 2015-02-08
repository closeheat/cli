var Requirer, acorn, coffee, fs, gulp, gutil, path, through;

fs = require('fs');

through = require('through2');

path = require('path');

gulp = require('gulp');

gutil = require('gutil');

coffee = require('gulp-coffee');

acorn = require('acorn');

module.exports = Requirer = (function() {
  function Requirer(dist) {
    this.dist = dist;
  }

  Requirer.prototype.scan = function() {
    console.log('Scanning');
    console.log(path.join(this.dist, '**/*.js'));
    console.log(path.join(this.dist, 'node_modules'));
    return gulp.src('/home/domas/Developer/cli-testing/**/*.js').pipe(this.scanner()).pipe(gulp.dest(path.join(this.dist, 'node_modules')));
  };

  Requirer.prototype.downloader = function(arg) {
    console.log('down');
    return console.log(arg);
  };

  Requirer.prototype.scanner = function(file) {
    return through.obj(function(file, enc, cb) {
      var ast, walk, walkall;
      console.log("File detected");
      if (file.isNull()) {
        return;
      }
      console.log(file.contents.toString());
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
        return console.log(module_name);
      }), walkall.traversers);
      return cb();
    });
  };

  return Requirer;

})();
