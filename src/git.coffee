if process.env.CLOSEHEAT_TEST
  module.exports = require '../test-dist/helpers/test_git'
else
  module.exports = require 'git-wrapper'
