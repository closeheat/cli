var Apps, git, gulp, q;

gulp = require('gulp');

git = require('gulp-git');

q = require('bluebird');

module.exports = Apps = (function() {
  function Apps() {}

  Apps.prototype.showList = function() {
    return console.log('list');
  };

  return Apps;

})();
