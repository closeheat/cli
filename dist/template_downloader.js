var Promise, TemplateDownloader, _, dirmr, fs, ghdownload, gulp, gutil, inject, path,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('lodash');

Promise = require('bluebird');

path = require('path');

ghdownload = require('github-download');

dirmr = require('dirmr');

fs = require('fs.extra');

gulp = require('gulp');

inject = require('gulp-inject');

gutil = require('gulp-util');

module.exports = TemplateDownloader = (function() {
  function TemplateDownloader(dirs, template1, framework) {
    this.dirs = dirs;
    this.template = template1;
    this.framework = framework;
    this.injectAssets = bind(this.injectAssets, this);
  }

  TemplateDownloader.prototype.download = function() {
    this.cleanTemplateDirs();
    return this.downloadFromGithub(this.template).then((function(_this) {
      return function() {
        return _this.downloadFromGithub(_this.framework);
      };
    })(this));
  };

  TemplateDownloader.prototype.downloadFromGithub = function(template) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        if (fs.existsSync(_this.templateDir(template))) {
          return resolve();
        }
        return ghdownload({
          user: 'closeheat',
          repo: "template-" + template,
          ref: 'master'
        }, _this.templateDir(template)).on('error', reject).on('end', resolve);
      };
    })(this));
  };

  TemplateDownloader.prototype.templateDir = function(template) {
    return path.join(this.dirs.parts, template);
  };

  TemplateDownloader.prototype.templateDirs = function() {
    return _.map([this.template, this.framework], (function(_this) {
      return function(template) {
        return _this.templateDir(template);
      };
    })(this));
  };

  TemplateDownloader.prototype.cleanTemplateDirs = function() {
    return _.each(this.templateDirs(), function(template) {
      if (fs.existsSync(template)) {
        return fs.rmrfSync(template);
      }
    });
  };

  TemplateDownloader.prototype.merge = function() {
    return this.joinDirs().then(this.injectAssets);
  };

  TemplateDownloader.prototype.joinDirs = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return dirmr(_this.templateDirs()).join(_this.dirs.whole).complete(function(err, result) {
          if (err) {
            return reject(err);
          }
          if (result) {
            return reject(result);
          }
          return resolve();
        });
      };
    })(this));
  };

  TemplateDownloader.prototype.injectAssets = function() {
    this.silenceGutil();
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var paths;
        paths = gulp.src([path.join(_this.dirs.whole, '**/*.min.css'), path.join(_this.dirs.whole, '**/*.css'), path.join(_this.dirs.whole, '**/*.min.js'), path.join(_this.dirs.whole, 'js/*.js')], {
          read: false
        });
        return gulp.src(path.join(_this.dirs.whole, 'index.html')).pipe(inject(paths, {
          relative: true,
          removeTags: true
        })).pipe(gulp.dest(_this.dirs.whole)).on('error', reject).on('end', (function() {
          _this.restoreGutil();
          return resolve();
        }));
      };
    })(this));
  };

  TemplateDownloader.prototype.silenceGutil = function() {
    this.original_log = gutil.log;
    return gutil.log = gutil.noop;
  };

  TemplateDownloader.prototype.restoreGutil = function() {
    return gutil.log = this.original_log;
  };

  return TemplateDownloader;

})();
