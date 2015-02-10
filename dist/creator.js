var Creator, Dirs, Prompt, Q, TemplateDownloader, Transformer, dirmr, fs, inquirer;

inquirer = require('inquirer');

fs = require('fs.extra');

dirmr = require('dirmr');

Q = require('q');

Prompt = require('./prompt');

Dirs = require('./dirs');

TemplateDownloader = require('./template_downloader');

Transformer = require('./transformer');

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.create = function(name) {
    this.dirs = new Dirs(name);
    if (fs.existsSync(this.dirs.target)) {
      console.log("Directory " + this.dirs.target + " already exists");
      return;
    }
    return inquirer.prompt(Prompt.questions, (function(_this) {
      return function(answers) {
        return _this.createFromSettings(answers);
      };
    })(this));
  };

  Creator.prototype.createFromSettings = function(answers) {
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
