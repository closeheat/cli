var DefaultGit, WithoutRemotesGit, _,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

DefaultGit = require('./default');

module.exports = WithoutRemotesGit = (function(superClass) {
  extend(WithoutRemotesGit, superClass);

  function WithoutRemotesGit() {
    return WithoutRemotesGit.__super__.constructor.apply(this, arguments);
  }

  WithoutRemotesGit.prototype.remote = function(args, cb) {
    return cb(null, "      ");
  };

  return WithoutRemotesGit;

})(DefaultGit);
