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
    throw new Error(resp.body.type);
  };

  return Errors;

})();
