var Authorized, Urls, User;

Urls = require('./urls');

Authorized = require('./authorized');

module.exports = User = (function() {
  function User() {}

  User.get = function() {
    return Authorized.post(Urls.user());
  };

  return User;

})();
