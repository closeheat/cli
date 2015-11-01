_ = require 'lodash'
DefaultGit = require './default'

module.exports = class WithoutRemotesGit extends DefaultGit
  remote: (args, cb) ->
    cb null,
      """
      """
