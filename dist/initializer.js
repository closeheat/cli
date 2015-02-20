var Initializer;

module.exports = Initializer = (function() {
  function Initializer() {}

  Initializer.prototype.init = function() {
    var deferred;
    deferred = Q.defer();
    git.init(function(err) {
      if (err) {
        throw err;
      }
      return deferred.resolve();
    });
    return deferred.promise;
  };

  return Initializer;

})();
