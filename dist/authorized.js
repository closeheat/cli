var Authorized, Authorizer, request, _,
  __slice = [].slice;

request = require('request');

_ = require('lodash');

Authorizer = require('./authorizer');

module.exports = Authorized = (function() {
  function Authorized() {}

  Authorized.request = function() {
    var cb, opts, params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    opts = params[0], cb = params[1];
    opts.qs = _.merge(opts.qs || {}, this.tokenParams());
    return request(opts, this.loginOnUnauthorized(opts, cb));
  };

  Authorized.tokenParams = function() {
    var authorizer;
    authorizer = new Authorizer;
    return {
      api_token: authorizer.accessToken()
    };
  };

  Authorized.loginOnUnauthorized = function(opts, cb) {
    return function(err, resp) {
      var authorizer;
      authorizer = new Authorizer();
      if (authorizer.unauthorized(resp)) {
        return authorizer.forceLogin(function() {
          return Authorized.request(opts, cb);
        });
      } else {
        return cb(err, resp);
      }
    };
  };

  return Authorized;

})();
