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

  Urls.githubAuthorized = function() {
    return (this.api()) + "/github-authorized";
  };

  Urls.appsIndex = function() {
    return (this.api()) + "/apps";
  };

  Urls.deployedSlug = function() {
    return (this.api()) + "/deploy/slug";
  };

  Urls.suggestSlug = function() {
    return (this.api()) + "/suggest/slug";
  };

  Urls.isFreeSlug = function() {
    return (this.api()) + "/free/slug";
  };

  Urls.publishNewWebsite = function() {
    return (this.api()) + "/deploy/new";
  };

  Urls.setupExistingRepo = function() {
    return (this.api()) + "/deploy/existing";
  };

  Urls.websiteDataFromRepo = function() {
    return (this.api()) + "/apps/from_repo";
  };

  Urls.websiteDataFromSlug = function() {
    return (this.api()) + "/apps/from_slug";
  };

  Urls.latestBuild = function(slug) {
    return (this.api()) + "/apps/" + slug + "/builds/latest";
  };

  Urls.buildForCLI = function(slug) {
    return (this.api()) + "/apps/" + slug + "/builds/for_cli";
  };

  Urls.createApp = function() {
    return (this.api()) + "/apps";
  };

  Urls.currentUser = function() {
    return (this.api()) + "/users/me";
  };

  Urls.getToken = function() {
    return (this.api()) + "/users/token";
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
