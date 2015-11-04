var Urls;

module.exports = Urls = (function() {
  function Urls() {}

  Urls.appData = function(app_name) {
    return (this.appsIndex()) + "/" + app_name;
  };

  Urls.base = function() {
    return 'http://app.closeheat.com';
  };

  Urls.api = function() {
    return global.API_URL;
  };

  Urls.appsIndex = function() {
    return (this.api()) + "/apps";
  };

  Urls.suggestSlug = function() {
    return (this.api()) + "/suggest/slug";
  };

  Urls.publish = function() {
    return (this.api()) + "/publish";
  };

  Urls.findApp = function() {
    return (this.api()) + "/apps/find";
  };

  Urls.buildForCLI = function(slug) {
    return (this.api()) + "/apps/" + slug + "/builds/for_cli";
  };

  Urls.currentUser = function() {
    return (this.api()) + "/users/me";
  };

  Urls.authorizeGitHub = function() {
    return (this.base()) + "/authorize-github";
  };

  Urls.notifier = function() {
    return (this.api()) + "/cli_notifier";
  };

  Urls.loginInstructions = function() {
    return (this.base()) + "/api/login";
  };

  return Urls;

})();
