var Deployer, Q, callback, git, gulp;

gulp = require('gulp');

git = require('gulp-git');

Q = require('q');

callback = require('gulp-callback');

module.exports = Deployer = (function() {
  var ALL_FILES;

  function Deployer() {}

  ALL_FILES = './**/*.*';

  Deployer.prototype.deploy = function() {
    return this.addEverything().then((function(_this) {
      return function() {
        return _this.commit('Deploying').then(function() {
          return _this.pushToMainBranch().then(function() {
            return _this.showDeployLog();
          });
        });
      };
    })(this));
  };

  Deployer.prototype.addEverything = function() {
    var deferred;
    deferred = Q.defer();
    gulp.src(ALL_FILES).pipe(git.add()).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Deployer.prototype.commit = function(msg) {
    var deferred, stream;
    deferred = Q.defer();
    console.log('commiting');
    stream = gulp.src(ALL_FILES).pipe(git.commit(msg));
    stream.on('end', function() {
      console.log('abc');
      return deferred.resolve();
    });
    return deferred.promise;
  };

  Deployer.prototype.pushToMainBranch = function() {
    var deferred;
    deferred = Q.defer();
    getMainBranch().then(function(main_branch) {
      console.log("got " + main_branch);
      return push(main_branch).then(function() {
        return deferred.resolve();
      });
    });
    return deferred.promise;
  };

  Deployer.prototype.getMainBranch = function() {
    var deferred;
    deferred = Q.defer();
    deferred.resolve('master');
    return deferred.promise;
  };

  Deployer.prototype.push = function(branch) {
    var deferred;
    deferred = Q.defer();
    console.log("pushing " + branch);
    git.push('origin', branch, function(err) {
      if (err) {
        throw err;
      }
      console.log('done');
      return deferred.resolve();
    });
    return deferred.promise;
  };

  Deployer.prototype.showDeployLog = function() {
    console.log('Deploying....');
    return console.log('Should be done.');
  };

  return Deployer;

})();
