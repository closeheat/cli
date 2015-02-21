var Color, Creator, Dirs, Log, Promise, Prompt, Pusher, TemplateDownloader, Transformer, dirmr, fs, inquirer, _;

inquirer = require('inquirer');

fs = require('fs.extra');

dirmr = require('dirmr');

Promise = require('bluebird');

_ = require('lodash');

Prompt = require('./prompt');

Dirs = require('./dirs');

TemplateDownloader = require('./template_downloader');

Transformer = require('./transformer');

Pusher = require('./pusher');

Log = require('./log');

Color = require('./color');

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
        return _this.createWithSettings(_.defaults(answers, settings))["catch"](function(err) {
          return console.log(err);
        });
      };
    })(this));
  };

  Creator.prototype.checkDir = function() {
    if (fs.existsSync(this.dirs.target)) {
      return Log.error("Directory " + this.dirs.target + " already exists");
    }
  };

  Creator.prototype.createWithSettings = function(answers) {
    Log.br();
    Log.spin('Downloading templates and creating app structure.');
    this.dirs.clean();
    return this.dirs.create().then((function(_this) {
      return function() {
        var downloader;
        downloader = new TemplateDownloader(_this.dirs, answers.template, answers.framework);
        return downloader.download().then(function() {
          return downloader.joinDirs().then(function() {
            return new Transformer(_this.dirs).transform(answers).then(function() {
              return _this.moveToTarget().then(function() {
                _this.dirs.clean();
                Log.stop();
                Log.inner("App folder created at " + _this.dirs.target + ".");
                if (!answers.deploy) {
                  return;
                }
                Log.br();
                Log.doneLine('Setting up deployment.');
                return new Pusher(answers.name, _this.dirs.target).push().then(function() {
                  Log.br();
                  Log.p("The app " + (Color.violet(answers.name)) + " has been created.");
                  Log.br();
                  Log.p("Run app server with:");
                  return Log.code(["cd " + answers.name, "closeheat"]);
                });
              });
            });
          });
        });
      };
    })(this))["catch"](function(e) {
      return Log.error(e);
    });
  };

  Creator.prototype.moveToTarget = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return dirmr([_this.dirs.transformed]).join(_this.dirs.target).complete(function(err, result) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  return Creator;

})();
