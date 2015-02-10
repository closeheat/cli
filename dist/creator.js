var Creator, Dirs, Prompt, Q, TemplateDownloader, Transformer, dirmr, fs, inquirer, _;

inquirer = require('inquirer');

fs = require('fs.extra');

dirmr = require('dirmr');

Q = require('q');

_ = require('lodash');

Prompt = require('./prompt');

Dirs = require('./dirs');

TemplateDownloader = require('./template_downloader');

Transformer = require('./transformer');

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.createFromSettings = function(name, settings) {
    var defaults;
    this.dirs = new Dirs(name);
    this.checkDir();
    defaults = {
      framework: 'angular',
      template: 'bootstrap',
      javascript: 'javascript',
      html: 'html',
      css: 'css'
    };
    return this.createWithSettings(_.defaults(settings, defaults));
  };

  Creator.prototype.createFromPrompt = function(name) {
    this.dirs = new Dirs(name);
    this.checkDir();
    return inquirer.prompt(Prompt.questions, (function(_this) {
      return function(answers) {
        console.log(answers);
        return _this.createWithSettings(answers);
      };
    })(this));
  };

  Creator.prototype.checkDir = function() {
    if (fs.existsSync(this.dirs.target)) {
      throw Error("Directory " + this.dirs.target + " already exists");
    }
  };

  Creator.prototype.createWithSettings = function(answers) {
    this.dirs.clean();
    return this.dirs.create().then((function(_this) {
      return function() {
        var downloader;
        downloader = new TemplateDownloader(_this.dirs, answers.framework, answers.template);
        return downloader.download().then(function() {
          return downloader.joinDirs().then(function() {
            return new Transformer(_this.dirs).transform(answers).then(function() {
              return _this.moveToTarget().then(function() {
                _this.dirs.clean();
                return console.log('Done');
              });
            });
          });
        });
      };
    })(this));
  };

  Creator.prototype.moveToTarget = function() {
    var deferred;
    deferred = Q.defer();
    dirmr([this.dirs.transformed]).join(this.dirs.target).complete(function(err, result) {
      if (err) {
        console.log(err);
      }
      if (result) {
        console.log(result);
      }
      return deferred.resolve();
    });
    return deferred.promise;
  };

  return Creator;

})();
