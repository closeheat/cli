var DefaultGit, WithoutRemotesGit, _,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

DefaultGit = require('./default');

global.TIMES_REMOTE_USED = 0;

module.exports = WithoutRemotesGit = (function(superClass) {
  extend(WithoutRemotesGit, superClass);

  function WithoutRemotesGit() {
    return WithoutRemotesGit.__super__.constructor.apply(this, arguments);
  }

  WithoutRemotesGit.prototype.remote = function(args, cb) {
    if (global.TIMES_REMOTE_USED === 0) {
      cb(null, "        ");
      return global.TIMES_REMOTE_USED = 1;
    } else {
      return cb(null, "origin  git@github.com:example-org/example-repo.git (fetch)\norigin  git@github.com:example-org/example-repo.git (push)");
    }
  };

  return WithoutRemotesGit;

})(DefaultGit);
