var Creator, Q, dirmr, fs, ghdownload, homePath, inquirer, mkdirp, path, _;

inquirer = require('inquirer');

fs = require('fs.extra');

path = require('path');

ghdownload = require('github-download');

_ = require('lodash');

Q = require('q');

homePath = require('home-path');

mkdirp = require('mkdirp');

dirmr = require('dirmr');

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.create = function(name) {
    this.src = process.cwd();
    this.tmp_dir = "" + (homePath()) + "/.closeheat/tmp/creations/353cleaned5sometime/";
    return inquirer.prompt([
      {
        message: 'Framework to use?',
        name: 'framework',
        type: 'list',
        choices: [
          {
            name: 'Angular.js',
            value: 'angular'
          }, {
            name: 'React.js',
            value: 'react'
          }, {
            name: 'Ember.js',
            value: 'ember'
          }, {
            name: 'None',
            value: 'none'
          }
        ]
      }, {
        message: 'Template?',
        name: 'template',
        type: 'list',
        choices: [
          {
            name: 'Bootstrap',
            value: 'bootstrap'
          }, {
            name: 'None',
            value: 'none'
          }
        ]
      }, {
        message: 'Javascript preprocessor?',
        name: 'javascript',
        type: 'list',
        "default": 'none',
        choices: [
          {
            name: 'CoffeeScript',
            value: 'coffeescript'
          }, {
            name: 'None',
            value: 'none'
          }
        ]
      }, {
        message: 'HTML preprocessor?',
        name: 'html',
        type: 'list',
        "default": 'none',
        choices: [
          {
            name: 'Jade',
            value: 'jade'
          }, {
            name: 'None',
            value: 'none'
          }
        ]
      }, {
        message: 'CSS preprocessor?',
        name: 'css',
        type: 'list',
        "default": 'none',
        choices: [
          {
            name: 'SCSS',
            value: 'scss'
          }, {
            name: 'None',
            value: 'none'
          }
        ]
      }
    ], (function(_this) {
      return function(answers) {
        return _this.createFromSettings(name, answers);
      };
    })(this));
  };

  Creator.prototype.createFromSettings = function(name, answers) {
    var app_dir, parts_dir, whole_dir;
    app_dir = path.join(process.cwd(), name);
    parts_dir = path.join(this.tmp_dir, 'parts');
    whole_dir = path.join(this.tmp_dir, 'whole');
    if (fs.existsSync(parts_dir)) {
      fs.rmrfSync(parts_dir);
    }
    if (fs.existsSync(whole_dir)) {
      fs.rmrfSync(whole_dir);
    }
    return mkdirp(parts_dir, (function(_this) {
      return function(err) {
        return mkdirp(whole_dir, function(err2) {
          var framework_dir, template_dir;
          if (err || err2) {
            console.log(err);
            console.log(err2);
          }
          framework_dir = path.join(_this.tmp_dir, 'parts', answers.framework);
          template_dir = path.join(_this.tmp_dir, 'parts', answers.template);
          return _this.downloadAndAdd(framework_dir, answers.framework).then(function() {
            return _this.downloadAndAdd(template_dir, answers.template).then(function() {
              console.log('before m');
              console.log(template_dir);
              console.log(whole_dir);
              dirmr([template_dir, framework_dir]).join(whole_dir);
              return console.log('merged');
            });
          });
        });
      };
    })(this));
  };

  Creator.prototype.downloadAndAdd = function(tmp, part) {
    var deferred;
    deferred = Q.defer();
    console.log("installing " + part);
    ghdownload({
      user: 'closeheat',
      repo: "template-" + part,
      ref: 'master'
    }, tmp).on('dir', function(dir) {
      return console.log("dir");
    }).on('error', function(err) {
      return console.log(err);
    }).on('end', function() {
      console.log('donw');
      return deferred.resolve(true);
    });
    return deferred.promise;
  };

  return Creator;

})();
