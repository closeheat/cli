var Apps, Authorizer, Color, Log, Urls, chalk, git, gulp, q, request, rp, table, util, _;

gulp = require('gulp');

git = require('gulp-git');

q = require('bluebird');

rp = require('request-promise');

request = require('request');

_ = require('lodash');

util = require('util');

table = require('text-table');

chalk = require('chalk');

Authorizer = require('./authorizer');

Urls = require('./urls');

Log = require('./log');

Color = require('./color');

module.exports = Apps = (function() {
  function Apps() {}

  Apps.prototype.list = function() {
    var authorizer, params;
    authorizer = new Authorizer;
    params = {
      api_token: authorizer.accessToken()
    };
    Log.logo();
    Log.spin('Getting information about your deployed apps.');
    return request({
      url: Urls.appsIndex(),
      qs: params,
      method: 'get'
    }, (function(_this) {
      return function(err, resp) {
        var apps, e;
        Log.spinStop();
        if (err) {
          return Log.error(err);
        }
        try {
          apps = JSON.parse(resp.body).apps;
        } catch (_error) {
          e = _error;
          return Log.error('Backend responded with an error.');
        }
        if (apps.length) {
          return _this.table(apps);
        } else {
          return _this.noApps();
        }
      };
    })(this));
  };

  Apps.prototype.table = function(apps) {
    var list;
    Log.inner("You have " + apps.length + " apps deployed.");
    Log.br();
    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]];
    _.each(apps, function(app) {
      return list.push(['', Color.violet(app.name), Color.bare("closeheat clone " + app.slug)]);
    });
    Log.line(table(list));
    Log.br();
    Log.line("Edit any of your apps by cloning it with:");
    Log.br();
    return Log.inner(Color.violet("closeheat clone your-awesome-app"));
  };

  Apps.prototype.noApps = function() {
    util.puts("You currently have no apps deployed.");
    util.puts("Create an app by typing:");
    return util.puts("  closeheat create my-awesome-app");
  };

  return Apps;

})();
