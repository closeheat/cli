var Color, Log, Opener, open;

open = require('open');

Log = require('./log');

Color = require('./color');

Opener = require('./opener');

module.exports = Opener = (function() {
  function Opener() {}

  Opener.prototype.open = function() {
    return Website.get().then(function(website) {
      if (!website.exists) {
        Log.p("No published website from this folder exists.");
        return Log.p("Type closeheat publish to create it.");
      }
      Log.p("Opening your website at " + website.url + ".");
      if (!process.env.CLOSEHEAT_TEST) {
        return open(website.url);
      }
    });
  };

  return Opener;

})();
