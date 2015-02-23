var Promise, TemplateDownloader, dirmr, fs, ghdownload, gulp, inject, path, _;

_ = require('lodash');

Promise = require('bluebird');

path = require('path');

ghdownload = require('github-download');

dirmr = require('dirmr');

fs = require('fs.extra');

module.exports = TemplateDownloader = (function() {
  function TemplateDownloader() {
    var dirs, templates;
    dirs = arguments[0], templates = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    this.dirs = dirs;
    this.templates = templates;
  }

  TemplateDownloader.prototype.download = function() {
    this.cleanTemplateDirs();
    return this.downloadFromGithub(this.templates[0]).then((function(_this) {
      return function() {
        return _this.downloadFromGithub(_this.templates[1]);
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
    return _.map(this.templates, (function(_this) {
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

  return TemplateDownloader;

})();
