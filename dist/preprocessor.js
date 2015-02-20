var Log, Preprocessor, Promise, callback, cssScss, gulp, gulpif, gutil, html2jade, js2coffee, path, through;

Promise = require('bluebird');

callback = require('gulp-callback');

gulp = require('gulp');

gutil = require('gulp-util');

cssScss = require('gulp-css-scss');

path = require('path');

js2coffee = require('gulp-js2coffee');

gulpif = require('gulp-if');

html2jade = require('html2jade');

through = require('through2');

Log = require('./log');

module.exports = Preprocessor = (function() {
  function Preprocessor(dirs) {
    this.dirs = dirs;
  }

  Preprocessor.prototype.ext = function(tech) {
    var EXTENTIONS;
    EXTENTIONS = {
      coffeescript: 'coffee',
      javascript: 'js',
      html: 'html',
      jade: 'jade',
      css: 'css',
      scss: 'scss'
    };
    return EXTENTIONS[tech];
  };

  Preprocessor.prototype.inverted = function(tech) {
    var PAIRS;
    PAIRS = {
      coffeescript: 'javascript',
      jade: 'html',
      scss: 'css'
    };
    return PAIRS[tech];
  };

  Preprocessor.prototype.sourceFor = function(tech) {
    return this.ext(this.inverted(tech) || tech);
  };

  Preprocessor.prototype.preprocessorFor = function(tech) {
    var PREPROCESSORS;
    PREPROCESSORS = {
      coffeescript: function() {
        return js2coffee();
      },
      jade: (function(_this) {
        return function() {
          return _this.jade({
            nspaces: 2
          });
        };
      })(this),
      scss: function() {
        return cssScss();
      }
    };
    return PREPROCESSORS[tech] || function() {
      return callback(function() {
        return 'no preprocessor';
      });
    };
  };

  Preprocessor.prototype.exec = function(tech) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return gulp.src(path.join(_this.dirs.whole, "**/*." + (_this.sourceFor(tech)))).pipe(gulpif(_this.notMinimized, _this.preprocessorFor(tech)())).pipe(gulp.dest(_this.dirs.transformed).on('error', Log.error)).on('end', resolve);
      };
    })(this));
  };

  Preprocessor.prototype.notMinimized = function(file) {
    return !file.path.match(/\.min\./);
  };

  Preprocessor.prototype.jade = function(options) {
    return through.obj(function(file, enc, cb) {
      var html;
      if (file.isNull()) {
        cb(null, file);
        return;
      }
      options = options || {};
      html = file.contents.toString();
      return html2jade.convertHtml(html, options, function(err, jade) {
        file.contents = new Buffer(jade);
        file.path = gutil.replaceExtension(file.path, ".jade");
        return cb(null, file);
      });
    });
  };

  return Preprocessor;

})();
