var Authorized, Promise, Urls, User;

Urls = require('./urls');

Authorized = require('./authorized');

Promise = require('bluebird');

module.exports = User = (function() {
  function User() {}

  User.get = function() {
    return new Promise(function(resolve, reject) {
      return Authorized.get(Urls.currentUser()).then(function(resp) {
        return resolve(resp.user);
      });
    });
  };

  return User;

})();
