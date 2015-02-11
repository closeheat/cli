var Deployer, Q, callback, git, gulp, gutil, q;

gulp = require('gulp');

git = require('gulp-git');

Q = require('q');

q = require('bluebird');

callback = require('gulp-callback');

gutil = require('gulp-util');

module.exports = Deployer = (function() {
  var ALL_FILES;

  function Deployer() {}

  ALL_FILES = '**';

  Deployer.prototype.deploy = function() {
    return this.addEverything().then((function(_this) {
      return function() {
        console.log('All files added.');
        return _this.commit('Deploy via CLI').then(function() {
          console.log('Commited.');
          console.log('Pushing to Github.');
          return _this.pushToMainBranch().then(function(branch) {
            console.log("Pushed to brach " + branch + " on Github.");
            return _this.showDeployLog();
          });
        })["catch"](function(e) {
          return console.log('No files to deploy.');
        });
      };
    })(this));
  };

  Deployer.prototype.addEverything = function() {
    return new q(function(resolve, reject) {
      var stream;
      gulp.src(ALL_FILES).pipe(stream = git.add()).on('error', reject).on('end', resolve);
      return stream.resume();
    });
  };

  Deployer.prototype.commit = function(msg) {
    return new q(function(resolve, reject) {
      var stream;
      gulp.src(ALL_FILES).pipe(stream = git.commit(msg)).on('error', reject).on('end', resolve);
      return stream.resume();
    });
  };

  Deployer.prototype.pushToMainBranch = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return _this.getMainBranch().then(function(main_branch) {
          return _this.push(main_branch).then(function() {
            return resolve(main_branch);
          });
        });
      };
    })(this));
  };

  Deployer.prototype.getMainBranch = function() {
    return new q(function(resolve, reject) {
      return resolve('master');
    });
  };

  Deployer.prototype.push = function(branch) {
    return new q(function(resolve, reject) {
      return git.push('origin', branch, {
        args: '--quiet'
      }, function(err) {
        if (err) {
          throw err;
        }
        return resolve();
      });
    });
  };

  Deployer.prototype.showDeployLog = function() {
    console.log('Deploying to closeheat.');
    console.log('............ SOME LOG HERE ..........');
    return console.log('Should be done.');
  };

  return Deployer;

})();
