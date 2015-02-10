var Q, TemplateDownloader, dirmr, ghdownload, path, _,
  __slice = [].slice;

_ = require('lodash');

Q = require('q');

path = require('path');

ghdownload = require('github-download');

dirmr = require('dirmr');

module.exports = TemplateDownloader = (function() {
  function TemplateDownloader() {
    var dirs, templates;
    dirs = arguments[0], templates = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    this.dirs = dirs;
    this.templates = templates;
  }

  TemplateDownloader.prototype.download = function() {
    return this.downloadFromGithub(this.templates[0]).then((function(_this) {
      return function() {
        return _this.downloadFromGithub(_this.templates[1]);
      };
    })(this));
  };

  TemplateDownloader.prototype.downloadFromGithub = function(template) {
    var deferred;
    deferred = Q.defer();
    ghdownload({
      user: 'closeheat',
      repo: "template-" + template,
      ref: 'master'
    }, this.templateDir(template)).on('error', function(err) {
      return console.log('ERROR: ', err);
    }).on('end', function() {
      return deferred.resolve();
    });
    return deferred.promise;
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

  TemplateDownloader.prototype.joinDirs = function() {
    var deferred;
    deferred = Q.defer();
    dirmr(this.templateDirs()).join(this.dirs.whole).complete(function(err, result) {
      if (err) {
        console.log('ERROR: ', err);
      }
      if (result) {
        console.log('ERROR: ', result);
      }
      return deferred.resolve();
    });
    return deferred.promise;
  };

  return TemplateDownloader;

})();
