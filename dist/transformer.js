var Preprocessor, Promise, Transformer, del, _;

Promise = require('bluebird');

_ = require('lodash');

del = require('del');

Preprocessor = require('./preprocessor');

module.exports = Transformer = (function() {
  function Transformer(dirs) {
    this.dirs = dirs;
    this.preprocessor = new Preprocessor(this.dirs);
  }

  Transformer.prototype.transform = function(answers) {
    return Promise.all(this.jobs(answers));
  };

  Transformer.prototype.remove = function(source_type) {
    return new Promise((function(_this) {
      return function(resolve, reject) {
        return del(["" + _this.dirs.dist + "/**/*." + source_type], function(err, paths) {
          if (err) {
            reject(err);
          }
          return resolve(paths);
        });
      };
    })(this));
  };

  Transformer.prototype.jobs = function(answers) {
    var result;
    result = [];
    if (answers.framework === 'react') {
      answers.javascript = 'jsx';
    }
    _.each([answers.html, answers.javascript, answers.css], (function(_this) {
      return function(tech) {
        if (!tech) {
          return;
        }
        return result.push(_this.preprocessor.exec(tech));
      };
    })(this));
    return result;
  };

  return Transformer;

})();
