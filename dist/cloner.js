var Authorizer, Cloner, Log, Q, Urls, callback, git, gulp, gutil, q, request, util;

gulp = require('gulp');

git = require('gulp-git');

Q = require('q');

q = require('bluebird');

callback = require('gulp-callback');

gutil = require('gulp-util');

request = require('request');

util = require('util');

Authorizer = require('./authorizer');

Urls = require('./urls');

Log = require('./log');

module.exports = Cloner = (function() {
  function Cloner() {}

  Cloner.prototype.clone = function(app_name) {
    Log.logo();
    Log.spin("Getting application data for " + app_name + ".");
    return this.getAppData(app_name).then((function(_this) {
      return function(app) {
        Log.stop();
        Log.spin("Cloning Github repository at " + app.github_repo + ".");
        return _this.execCloning(app.github_repo, app.default_branch, app_name).then(function() {
          Log.stop();
          Log.inner("Cloned the app code to directory '" + app_name + "'.");
          Log.br();
          Log.line('Run the server by typing:');
          Log.code(["cd " + app_name, 'closeheat']);
          Log.br();
          Log.p('The quickest way to deploy changes to closeheat.com and Github is with:');
          Log.secondaryCode('closeheat deploy');
          Log.br();
          Log.p('For more awesome tricks type:');
          return Log.secondaryCode('closeheat help');
        });
      };
    })(this));
  };

  Cloner.prototype.getAppData = function(app_name) {
    var authorizer, params;
    authorizer = new Authorizer;
    params = {
      api_token: authorizer.accessToken()
    };
    return new q(function(resolve, reject) {
      return request({
        url: Urls.appData(app_name),
        qs: params,
        method: 'get'
      }, function(err, resp) {
        var app;
        app = JSON.parse(resp.body).app;
        return resolve(app);
      });
    });
  };

  Cloner.prototype.execCloning = function(github_repo, branch, app_name) {
    return new q(function(resolve, reject) {
      return git.clone("git@github.com:" + github_repo + ".git", {
        args: "" + app_name,
        quiet: true
      }, function(err) {
        if (err) {
          throw err;
        }
        return resolve();
      });
    });
  };

  Cloner.prototype.showDeployLog = function() {
    console.log('Deploying to closeheat.');
    console.log('............ SOME LOG HERE ..........');
    return console.log('Should be done.');
  };

  return Cloner;

})();
