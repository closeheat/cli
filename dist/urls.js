var Urls;

module.exports = Urls = (function() {
  function Urls() {}

  Urls.appData = function(app_name) {
    return "" + (this.appsIndex()) + "/" + app_name;
  };

  Urls.appsIndex = function() {
    return 'http://staging.closeheat.com/api/apps';
  };

  return Urls;

})();
