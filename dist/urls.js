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
    return 'http://api.closeheat.com';
  };

  Urls.appsIndex = function() {
    return "" + (this.api()) + "/apps";
  };

  Urls.createApp = function() {
    return "" + (this.api()) + "/apps";
  };

  Urls.currentUserInfo = function() {
    return "" + (this.api()) + "/users/me";
  };

  Urls.authorizeGithub = function() {
    return "" + (this.base()) + "/authorize-github";
  };

  return Urls;

})();
