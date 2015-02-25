var Urls;

module.exports = Urls = (function() {
  function Urls() {}

  Urls.appData = function(app_name) {
    return "" + (this.appsIndex()) + "/" + app_name;
  };

  Urls.base = function() {
    return 'http://app.closeheat.com';
  };

  Urls.api = function() {
    'http://api.closeheat.com';
    return 'http://10.30.0.1:4000/api';
  };

  Urls.appsIndex = function() {
    return "" + (this.api()) + "/apps";
  };

  Urls.deployStatus = function() {
    return "" + (this.api()) + "/deploy/status";
  };

  Urls.createApp = function() {
    return "" + (this.api()) + "/apps";
  };

  Urls.currentUserInfo = function() {
    return "" + (this.api()) + "/users/me";
  };

  Urls.getToken = function() {
    return "" + (this.api()) + "/users/token";
  };

  Urls.authorizeGithub = function() {
    return "" + (this.base()) + "/authorize-github";
  };

  return Urls;

})();
