var Authorized, Color, Config, Permissions, Promise, Urls, fs, inquirer, open, pkg, request;

fs = require('fs');

inquirer = require('inquirer');

request = require('request');

pkg = require('../package.json');

Promise = require('bluebird');

open = require('open');

Urls = require('./urls');

Color = require('./color');

Config = require('./config');

Authorized = require('./authorized');

module.exports = Permissions = (function() {
  function Permissions() {}

  Permissions.check = function(resp) {
    if (!resp[0]) {
      return;
    }
    return this.report(resp[0]);
  };

  Permissions.report = function(resp) {
    var Log;
    Log = require('./log');
    Log.stop();
    Log.error(JSON.stringify(resp));
    return process.exit();
  };

  return Permissions;

})();
