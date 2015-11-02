var Permissions, Urls;

Urls = require('./urls');

module.exports = Permissions = (function() {
  function Permissions() {}

  Permissions.check = function(resp) {
    if (!resp[0]) {
      return;
    }
    if (resp[0].statusCode === 200) {
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
