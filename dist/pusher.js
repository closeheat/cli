var Authorized, Color, Deployer, Git, Log, Promise, Pusher, Urls, shell, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('lodash');

Promise = require('bluebird');

shell = require('shelljs');

Git = require('git-wrapper');

Urls = require('./urls');

Deployer = require('./deployer');

Log = require('./log');

Color = require('./color');

Authorized = require('./authorized');

module.exports = Pusher = (function() {
  function Pusher(name, target) {
    this.name = name;
    this.target = target;
    this.initGit = __bind(this.initGit, this);
    this.addRemote = __bind(this.addRemote, this);
    this.pushFiles = __bind(this.pushFiles, this);
    this.createAppInBackend = __bind(this.createAppInBackend, this);
    this.git = new Git();
  }

  Pusher.prototype.push = function() {
    return this.getGithubUsername().then((function(_this) {
      return function(username) {
        Log.inner("Using Github username: " + (Color.orange(username)));
        Log.spin('Creating closeheat app and Github repository.');
        return _this.createAppInBackend().then(function() {
          Log.stop();
          Log.inner("Created both with name '" + _this.name + "'.");
          return _this.pushFiles(username).then(function() {
            Log.br();
            Log.p("The app " + (Color.violet(_this.name)) + " has been created.");
            return Log.br();
          });
        });
      };
    })(this))["catch"](function(err) {
      return Log.error(err);
    });
  };

  Pusher.prototype.githubNotAuthorized = function() {
    Log.error('Github not authorized', false);
    Log.innerError("We cannot set you up for deployment because you did not authorize Github.");
    Log.br();
    return Log.innerError("Visit " + (Urls.authorizeGithub()) + " and rerun the command.");
  };

  Pusher.prototype.createAppInBackend = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.createApp(),
          qs: {
            repo_name: _this.name
          },
          method: 'post',
          json: true
        }, function(err, resp) {
          if (err) {
            return reject(err);
          }
          if (resp.body.status === 'error') {
            return reject(resp.body.msg);
          }
          return resolve(resp);
        });
      };
    })(this));
  };

  Pusher.prototype.getGithubUsername = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.request({
          url: Urls.currentUserInfo(),
          method: 'get'
        }, function(err, resp) {
          var e, user_info;
          if (err) {
            return reject(err);
          }
          try {
            user_info = JSON.parse(resp.body).user;
          } catch (_error) {
            e = _error;
            return Log.error('Backend responded with an error.');
          }
          if (user_info['github_token']) {
            return resolve(user_info['github_username']);
          } else {
            return _this.githubNotAuthorized();
          }
        });
      };
    })(this));
  };

  Pusher.prototype.pushFiles = function(username) {
    shell.cd(this.target);
    return this.initGit().then((function(_this) {
      return function() {
        _this.addRemote(username).then(function() {});
        return new Deployer().deploy().then(function() {
          return shell.cd('..');
        });
      };
    })(this));
  };

  Pusher.prototype.addRemote = function(username) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        var git_url;
        git_url = "git@github.com:" + username + "/" + _this.name + ".git";
        return _this.git.exec('remote', ['add', 'origin', git_url], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  Pusher.prototype.initGit = function() {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.git.exec('init', [_this.target], function(err, resp) {
          if (err) {
            return reject(err);
          }
          return resolve();
        });
      };
    })(this));
  };

  return Pusher;

})();
