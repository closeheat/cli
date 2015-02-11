var Deployer, Q, git, gulp;

gulp = require('gulp');

git = require('gulp-git');

Q = require('q');

module.exports = Deployer = (function() {
  function Deployer() {}

  Deployer.prototype.deploy = function() {
    return addEverything().then(function() {
      return commit('Deploying').then(function() {
        return pushToMainBranch().then(function() {
          return showDeployLog();
        });
      });
    });
  };

  Deployer.prototype.addEverything = function() {
    var deferred;
    deferred = Q.deferred();
    gulp.src('./**.*').pipe(git.add()).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Deployer.prototype.commit = function(msg) {
    var deferred;
    deferred = Q.deferred();
    gulp.src('./**.*').pipe(git.commit(msg)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Deployer.prototype.pushToMainBranch = function() {
    return getMainBranch().then(function(main_branch) {
      return push(main_branch);
    });
  };

  Deployer.prototype.getMainBranch = function() {
    var deferred;
    deferred = Q.deferred();
    deferred.resolve('master');
    return deferred.promise;
  };

  Deployer.prototype.push = function(branch) {
    var deferred;
    deferred = Q.deferred();
    gulp.src('./**.*').pipe(git.push('origin', branch)).pipe(callback(function() {
      return deferred.resolve();
    }));
    return deferred.promise;
  };

  Deployer.prototype.showDeployLog = function() {
    console.log('Deploying....');
    return console.log('Should be done.');
  };

  return Deployer;

})();
