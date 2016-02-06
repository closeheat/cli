var TestPusher;

module.exports = TestPusher = (function() {
  function TestPusher() {}

  TestPusher.prototype.subscribe = function() {
    return this;
  };

  TestPusher.prototype.bind = function(event, fn) {
    return fn();
  };

  return TestPusher;

})();
