if process.env.CLOSEHEAT_TEST
  module.exports = require '../test/helpers/dist/test_git'
else
  module.exports = require 'git-wrapper'
