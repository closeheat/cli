var Creator, Q, callback, cssScss, dirmr, exec, fs, ghdownload, ghtml2jade, gulp, gutil, homePath, html2jade, inquirer, js2coffee, mkdirp, path, through, _;

inquirer = require('inquirer');

fs = require('fs.extra');

path = require('path');

ghdownload = require('github-download');

_ = require('lodash');

Q = require('q');

homePath = require('home-path');

mkdirp = require('mkdirp');

dirmr = require('dirmr');

ghtml2jade = require('gulp-html2jade');

gulp = require('gulp');

gutil = require('gulp-util');

html2jade = require('html2jade');

through = require('through2');

callback = require('gulp-callback');

js2coffee = require('gulp-js2coffee');

cssScss = require('gulp-css-scss');

exec = require('exec');

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.create = function(name) {
    this.app_dir = path.join(process.cwd(), name);
    if (fs.existsSync(this.app_dir)) {
      console.log("Dir " + this.app_dir + " already exists");
      return;
    }
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
    var parts_dir, transformed_dir, whole_dir;
    parts_dir = path.join(this.tmp_dir, 'parts');
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
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
              return dirmr([template_dir, framework_dir]).join(whole_dir).complete(function(err, result) {
                return _this.transform(answers, _this.app_dir);
              });
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
    }).on('zip', function() {
      return console.log('REACHED GITHUB LIMITS');
    }).on('end', function() {
      console.log('donw');
      return deferred.resolve(true);
    });
    return deferred.promise;
  };

  Creator.prototype.transform = function(answers, app_dir) {
    var transformed_dir, whole_dir;
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
    if (fs.existsSync(transformed_dir)) {
      fs.rmrfSync(transformed_dir);
    }
    return mkdirp(transformed_dir, (function(_this) {
      return function(err) {
        var jobs;
        if (err) {
          console.log(err);
        }
        jobs = [];
        if (answers.html === 'jade') {
          jobs.push(_this.preprocessJade());
        } else {
          jobs.push(_this.move('html'));
        }
        if (answers.javascript === 'coffeescript') {
          jobs.push(_this.preprocessCoffeeScript());
        } else {
          jobs.push(_this.move('js'));
        }
        if (answers.css === 'scss') {
          jobs.push(_this.preprocessSCSS());
        } else {
          jobs.push(_this.move('css'));
        }
        return Q.when.apply(Q, jobs).then(function() {
          return dirmr([transformed_dir]).join(app_dir).complete(function(err, result) {
            console.log(err);
            console.log(result);
            fs.rmrfSync(transformed_dir);
            return console.log('all done!');
          });
        });
      };
    })(this));
  };

  Creator.prototype.move = function(ext) {
    var deferred, transformed_dir, whole_dir;
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
    deferred = Q.defer();
    gulp.src(path.join(whole_dir, "**/*." + ext)).pipe(gulp.dest(transformed_dir).on('error', gutil.log)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Creator.prototype.preprocessSCSS = function() {
    var deferred, transformed_dir, whole_dir;
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
    deferred = Q.defer();
    gulp.src(path.join(whole_dir, "**/*.css")).pipe(cssScss()).pipe(gulp.dest(transformed_dir).on('error', gutil.log)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Creator.prototype.preprocessJade = function() {
    var deferred, transformed_dir, whole_dir;
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
    deferred = Q.defer();
    gulp.src(path.join(whole_dir, '**/*.html')).pipe(this.gulpHtmlToJade({
      nspaces: 2
    }).on('error', gutil.log)).pipe(gulp.dest(transformed_dir).on('error', gutil.log)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Creator.prototype.preprocessCoffeeScript = function() {
    var deferred, transformed_dir, whole_dir;
    whole_dir = path.join(this.tmp_dir, 'whole');
    transformed_dir = path.join(this.tmp_dir, 'transformed');
    deferred = Q.defer();
    gulp.src(path.join(whole_dir, '**/*.js')).pipe(js2coffee().on('error', gutil.log)).pipe(gulp.dest(transformed_dir)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Creator.prototype.gulpHtmlToJade = function(options) {
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

  return Creator;

})();
