var Authorized, Authorizer, Log, Promise, _, pkg, request;

Promise = require('bluebird');

request = Promise.promisify(require('request'));

_ = require('lodash');

pkg = require('../package.json');

Authorizer = require('./authorizer');

Log = require('./log');

module.exports = Authorized = (function() {
  function Authorized() {}

  Authorized.request = function(opts) {
    Log = require('./log');
    if (!_.isPlainObject(opts)) {
      Log.error("Request opts is not an object: " + opts);
    }
    if (!this.token()) {
      Log.error('Log in please');
    }
    opts.qs = _.merge(opts.qs || {}, {
      api_token: this.token()
    });
    opts.headers = {
      'X-CLI-Version': pkg.version
    };
    return request(opts);
  };

  Authorized.post = function(url, data) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return _this.request({
          url: url,
          qs: data,
          json: true,
          method: 'post'
        }).then(function(resp) {
          return resolve(resp[0].body);
        })["catch"](function() {
          console.log('CATCH');
          return reject;
        });
      };
    })(this));
  };

  Authorized.token = function() {
    var authorizer, result;
    Authorizer = require('./authorizer');
    authorizer = new Authorizer();
    result = authorizer.accessToken();
    if (result === 'none' || !result) {
      return null;
    }
    return result;
  };

  return Authorized;

})();
