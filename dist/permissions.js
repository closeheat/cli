var Color, Permissions, Urls;

Urls = require('./urls');

Color = require('./color');

module.exports = Permissions = (function() {
  function Permissions() {}

  Permissions.check = function(resp) {
    if (!resp[0]) {
      return;
    }
    if (resp[0].statusCode !== 401) {
      return;
    }
    return this.report(resp[0]);
  };

  Permissions.report = function(resp) {
    var Log;
    Log = require('./log');
    Log.stop();
    switch (resp.body.type) {
      case 'user-unauthorized':
        Log.p(Color.redYellow('You need to log in for that.'));
        Log.p("Type " + (Color.violet('closeheat login')) + " to do it swiftly.");
        break;
      case 'github-unauthorized':
        Log.error('GitHub not authorized');
        Log.innerError("We cannot set you up for deployment because you did not authorize GitHub.", false);
        Log.br();
        Log.innerError("Visit " + (Urls.authorizeGitHub()) + " and rerun the command.");
        break;
      default:
        Log.error("Authorization failed - it shouldn't fail like that though.");
        Log.error("Shoot an email to support@closeheat.com and we'll figure it out.");
    }
    return process.exit();
  };

  return Permissions;

})();
