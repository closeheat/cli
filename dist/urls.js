var Urls;

module.exports = Urls = (function() {
  function Urls() {}

  Urls.appData = function(app_name) {
    return "" + (this.appsIndex()) + "/" + app_name;
  };

  Urls.base = function() {
    'http://staging.closeheat.com';
    return 'http://10.30.0.1:4000';
  };

  Urls.appsIndex = function() {
    return "" + (this.base()) + "/api/apps";
  };

  Urls.createApp = function() {
    return "" + (this.base()) + "/api/apps";
  };

  Urls.currentUserInfo = function() {
    return "" + (this.base()) + "/api/users/me";
  };

  Urls.authorizeGithub = function() {
    return "" + (this.base()) + "/authorize-github";
  };

  return Urls;

})();
