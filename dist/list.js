var Authorized, Color, List, Log, Promise, Urls, _, table,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Promise = require('bluebird');

_ = require('lodash');

table = require('text-table');

Authorized = require('./authorized');

Urls = require('./urls');

Log = require('./log');

Color = require('./color');

module.exports = List = (function() {
  function List() {
    this.show = bind(this.show, this);
  }

  List.prototype.show = function() {
    Log.logo();
    Log.spin('Getting information about your websites.');
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return Authorized.get(Urls.appsIndex()).then(function(resp) {
          Log.stop();
          if (resp.apps.length) {
            _this.table(resp.apps);
          } else {
            _this.noApps();
          }
          return resolve();
        });
      };
    })(this));
  };

  List.prototype.table = function(apps) {
    var list;
    Log.inner("You have " + apps.length + " websites.");
    list = [['', Color.redYellow('Name'), Color.redYellow(' Clone command')]];
    _.each(apps, function(app) {
      return list.push(['', Color.violet(app.name), Color.bare("closeheat clone " + app.slug)]);
    });
    Log.br();
    Log.line(table(list));
    Log.br();
    Log.line('Edit any of your websites by cloning it with:');
    return Log.code('closeheat clone awesome-website');
  };

  List.prototype.noApps = function() {
    Log.inner('You have no websites.');
    Log.br();
    Log.line('Publish this folder as a website by typing:');
    return Log.code('closeheat deploy your-website-name');
  };

  return List;

})();
