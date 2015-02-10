var JadePreprocessor, Preprocessor, Q, callback, cssScss, gulp, gutil, js2coffee, path;

Q = require('q');

callback = require('gulp-callback');

gulp = require('gulp');

gutil = require('gulp-util');

cssScss = require('gulp-css-scss');

path = require('path');

js2coffee = require('gulp-js2coffee');

JadePreprocessor = require('./jade_preprocessor');

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
      jade: function() {
        return new JadePreprocessor.exec({
          nspaces: 2
        });
      },
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
    var deferred;
    deferred = Q.defer();
    gulp.src(path.join(this.dirs.whole, "**/*." + (this.sourceFor(tech)))).pipe(this.preprocessorFor(tech)()).pipe(gulp.dest(this.dirs.transformed).on('error', gutil.log)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  return Preprocessor;

})();
