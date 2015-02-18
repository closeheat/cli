var Creator, Dirs, Prompt, Pusher, Q, TemplateDownloader, Transformer, dirmr, fs, inquirer, _;

inquirer = require('inquirer');

fs = require('fs.extra');

dirmr = require('dirmr');

Q = require('q');

_ = require('lodash');

Prompt = require('./prompt');

Dirs = require('./dirs');

TemplateDownloader = require('./template_downloader');

Transformer = require('./transformer');

Pusher = require('./pusher');

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.createFromSettings = function(settings) {
    var defaults;
    this.dirs = new Dirs(settings);
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

  Creator.prototype.createFromPrompt = function(settings) {
    this.dirs = new Dirs(settings);
    this.checkDir();
    return inquirer.prompt(Prompt.questions, (function(_this) {
      return function(answers) {
        return _this.createWithSettings(_.defaults(answers, settings));
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
                console.log("Getting app ready for deployment...");
                return new Pusher(answers.name, _this.dirs.target).push().then(function() {
                  console.log("The app " + answers.name + " has been created.");
                  console.log("Run app server with:");
                  console.log("  cd " + answers.name);
                  return console.log("  closeheat");
                });
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
