open = require 'open'

Urls = require './urls'

module.exports =
class GitHubAuthorizer
  open: ->
    Log = require './log'

    Log.doneLine("Authorize GitHub at #{Urls.authorizeGitHub()} in your browser.")
    open(Urls.authorizeGitHub()) unless process.env.CLOSEHEAT_TEST
