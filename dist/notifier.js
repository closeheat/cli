var Authorizer, Notifier, Urls, pkg, request;

Urls = require('./urls');

Authorizer = require('./authorizer');

request = require('request');

pkg = require('../package.json');

module.exports = Notifier = (function() {
  function Notifier() {}

  Notifier.notify = function(action, app_slug) {
    var authorizer, parameters, request_options;
    if (app_slug == null) {
      app_slug = void 0;
    }
    authorizer = new Authorizer;
    parameters = {
      name: action,
      api_token: authorizer.accessToken(),
      app_slug: app_slug
    };
    request_options = {
      url: Urls.notifier(),
      body: JSON.stringify(parameters),
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'X-CLI-Version': pkg.version
      }
    };
    request(request_options);
    return true;
  };

  return Notifier;

})();
