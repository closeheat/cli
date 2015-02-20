var Apps, Authorizer, Color, Log, Urls, request, table, _;

request = require('request');

_ = require('lodash');

table = require('text-table');

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
        Log.stop();
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
    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]];
    _.each(apps, function(app) {
      return list.push(['', Color.violet(app.name), Color.bare("closeheat clone " + app.slug)]);
    });
    Log.br();
    Log.line(table(list));
    Log.br();
    Log.line("Edit any of your apps by cloning it with:");
    return Log.code("closeheat clone your-awesome-app");
  };

  Apps.prototype.noApps = function() {
    Log.inner("You have no apps deployed.");
    Log.br();
    Log.line("Create an app by typing:");
    return Log.code("closeheat create your-awesome-app");
  };

  return Apps;

})();
