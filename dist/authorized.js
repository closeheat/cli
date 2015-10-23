var Authorized, Authorizer, Log, _, pkg, request,
  slice = [].slice;

request = require('request');

_ = require('lodash');

pkg = require('../package.json');

Authorizer = require('./authorizer');

Log = require('./log');

module.exports = Authorized = (function() {
  function Authorized() {}

  Authorized.request = function() {
    var cb, opts, params, token_params;
    params = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    opts = params[0], cb = params[1];
    token_params = this.tokenParams(opts, cb);
    if (token_params) {
      opts.qs = _.merge(opts.qs || {}, token_params);
      opts.headers = {
        'X-CLI-Version': pkg.version
      };
      return request(opts, this.loginOnUnauthorized(opts, cb));
    }
  };

  Authorized.tokenParams = function(opts, cb) {
    var api_token, authorizer;
    authorizer = new Authorizer;
    api_token = authorizer.accessToken();
    if (api_token === 'none' || !api_token) {
      authorizer.forceLogin((function(_this) {
        return function() {
          return _this.request(opts, cb);
        };
      })(this));
      return false;
    }
    return {
      api_token: api_token
    };
  };

  Authorized.loginOnUnauthorized = function(opts, cb) {
    return function(err, resp) {
      var authorizer;
      if (err) {
        Log.error(err);
      }
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
