var Authorizer, Deployer, Pusher, Urls, fs, git, q, request, shell, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

request = require('request');

_ = require('lodash');

q = require('bluebird');

git = require('gulp-git');

fs = require('fs-extra');

shell = require('shelljs');

Authorizer = require('./authorizer');

Urls = require('./urls');

Deployer = require('./deployer');

module.exports = Pusher = (function() {
  function Pusher(name, target) {
    var authorizer;
    this.name = name;
    this.target = target;
    this.initGit = __bind(this.initGit, this);
    this.addRemote = __bind(this.addRemote, this);
    this.pushFiles = __bind(this.pushFiles, this);
    this.createAppInBackend = __bind(this.createAppInBackend, this);
    this.githubNotAuthorized = __bind(this.githubNotAuthorized, this);
    this.handleCreationError = __bind(this.handleCreationError, this);
    authorizer = new Authorizer;
    this.token_params = {
      api_token: authorizer.accessToken()
    };
  }

  Pusher.prototype.push = function() {
    console.log('pushin');
    return this.getGithubUsername().then((function(_this) {
      return function(username) {
        console.log('auth');
        return _this.createAppInBackend().then(function(resp) {
          console.log('created');
          return _this.pushFiles(username).then(function() {
            return console.log('files pushed');
          });
        });
      };
    })(this));
  };

  Pusher.prototype.handleCreationError = function(error) {
    return console.log(error);
  };

  Pusher.prototype.githubNotAuthorized = function() {
    console.log("We cannot set you up for deployment because you did not authorize Github.");
    console.log("");
    return console.log("Visit " + (Urls.authorizeGithub()) + " and rerun the command.");
  };

  Pusher.prototype.createAppInBackend = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return request({
          url: Urls.createApp(),
          qs: _.merge({
            repo_name: _this.name
          }, _this.token_params),
          method: 'post'
        }, function(err, resp) {
          console.log('created');
          if (err) {
            return _this.handleCreationError(error);
          }
          return resolve(resp);
        });
      };
    })(this));
  };

  Pusher.prototype.getGithubUsername = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return request({
          url: Urls.currentUserInfo(),
          qs: _this.token_params,
          method: 'get'
        }, function(err, resp) {
          var user_info;
          if (err) {
            throw Error('Error happened');
          }
          user_info = JSON.parse(resp.body).user;
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
    return this.initGit().then((function(_this) {
      return function() {
        console.log('inited');
        _this.addRemote(username);
        console.log('remote added');
        shell.cd(_this.target);
        return new Deployer().deploy("" + _this.target + "/**").then(function() {
          return shell.cd('..');
        });
      };
    })(this));
  };

  Pusher.prototype.addRemote = function(username) {
    var content;
    content = "[remote \"origin\"]\n        url = git@github.com:" + username + "/" + this.name + ".git\n        fetch = +refs/heads/*:refs/remotes/origin/*";
    return fs.appendFileSync("" + this.target + "/.git/config", content);
  };

  Pusher.prototype.initGit = function() {
    return new q((function(_this) {
      return function(resolve, reject) {
        return git.init({
          args: "" + _this.target + " --quiet"
        }, function(err) {
          if (err) {
            throw err;
          }
          return resolve();
        });
      };
    })(this));
  };

  return Pusher;

})();
