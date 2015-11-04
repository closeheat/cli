var Errors, Urls;

Urls = require('./urls');

module.exports = Errors = (function() {
  function Errors() {}

  Errors.check = function(resp) {
    if (!resp[0]) {
      return;
    }
    if (resp[0].statusCode === 200) {
      return;
    }
    return this.report(resp[0]);
  };

  Errors.report = function(resp) {
    var Log;
    Log = require('./log');
    Log.stop();
    switch (resp.body.type) {
      case 'app-not-found':
        Log.p("Could not find this website.");
        break;
      default:
        Log.error(JSON.stringify(resp));
    }
    return process.exit();
  };

  return Errors;

})();
