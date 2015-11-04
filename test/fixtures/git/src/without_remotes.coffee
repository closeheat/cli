_ = require 'lodash'
DefaultGit = require './default'

global.TIMES_REMOTE_USED = 0

module.exports = class WithoutRemotesGit extends DefaultGit
  remote: (args, cb) ->
    if global.TIMES_REMOTE_USED == 0
      cb null,
        """
        """
      global.TIMES_REMOTE_USED = 1
    else
      cb null,
        """
        origin  git@github.com:example-org/example-repo.git (fetch)
        origin  git@github.com:example-org/example-repo.git (push)
        """
