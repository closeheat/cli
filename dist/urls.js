var Urls;

module.exports = Urls = (function() {
  function Urls() {}

  Urls.appData = function(app_name) {
    return "" + (this.appsIndex()) + "/" + app_name;
  };

  Urls.appsIndex = function() {
    'http://staging.closeheat.com/api/apps';
    return 'http://10.30.0.1:4000/api/apps';
  };

  return Urls;

})();
