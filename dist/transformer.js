var Preprocessor, Q, Transformer, _;

Q = require('q');

_ = require('lodash');

Preprocessor = require('./preprocessor');

module.exports = Transformer = (function() {
  function Transformer(dirs) {
    this.dirs = dirs;
    this.preprocessor = new Preprocessor(this.dirs);
  }

  Transformer.prototype.transform = function(answers) {
    return Q.when.apply(Q, this.jobs(answers));
  };

  Transformer.prototype.jobs = function(answers) {
    var result;
    result = [];
    _.each([answers.html, answers.javascript, answers.css], (function(_this) {
      return function(tech) {
        return result.push(_this.preprocessor.exec(tech));
      };
    })(this));
    return result;
  };

  return Transformer;

})();
