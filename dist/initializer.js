var Authorized, Initializer, Log, Promise, Urls, inquirer, path;

inquirer = require('inquirer');

path = require('path');

Promise = require('bluebird');

Urls = require('./urls');

Authorized = require('./authorized');

Log = require('./log');

module.exports = Initializer = (function() {
  function Initializer() {}

  Initializer.prototype.init = function() {
    var default_app_name;
    default_app_name = path.basename(process.cwd());
    return new Promise(function(resolve, reject) {
      return inquirer.prompt({
        message: 'How should we name your Github repo?',
        name: 'name',
        "default": default_app_name
      }, function(answer) {
        var Pusher, pusher;
        Log.br();
        Pusher = require('./pusher');
        pusher = new Pusher(answer.name, process.cwd());
        return pusher.push();
      });
    });
  };

  return Initializer;

})();
