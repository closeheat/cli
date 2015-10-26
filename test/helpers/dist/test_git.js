var TestGit, _,
  slice = [].slice;

_ = require('lodash');

module.exports = TestGit = (function() {
  function TestGit() {}

  TestGit.prototype.exec = function() {
    var args, cb, cmd, i, pretty_cmd;
    cmd = arguments[0], args = 3 <= arguments.length ? slice.call(arguments, 1, i = arguments.length - 1) : (i = 1, []), cb = arguments[i++];
    pretty_cmd = ['git', cmd, this.prettyArgs(args)];
    console.log("\nTEST: Executing '" + (pretty_cmd.join(' ')) + "'");
    if (this[_.camelCase(cmd)]) {
      return this[_.camelCase(cmd)](args, cb);
    } else {
      return cb(null, null);
    }
  };

  TestGit.prototype.prettyArgs = function(all_args) {
    var result;
    result = _.map(all_args, function(args) {
      if (_.isArray(args)) {
        return args.join(' ');
      } else if (_.isPlainObject(args)) {
        return _.map(args, function(v, k) {
          return k + ": " + v;
        }).join(' ');
      } else {
        return args.toString();
      }
    });
    return result.join(' ');
  };

  TestGit.prototype.remote = function(args, cb) {
    return cb(null, "heroku       git://github.com/other-org/other-repo.git (fetch)\nheroku        git://github.com/other-org/other-repo.git (push)\norigin  git@github.com:example-org/example-repo.git (fetch)\norigin  git@github.com:example-org/example-repo.git (push)");
  };

  TestGit.prototype.symbolicRef = function(args, cb) {
    return cb(null, 'example-branch');
  };

  return TestGit;

})();
