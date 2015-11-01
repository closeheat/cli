fs = require 'fs'
inquirer = require 'inquirer'
request = require 'request'
pkg = require '../package.json'
Promise = require 'bluebird'
open = require 'open'

Urls = require './urls'
Color = require './color'
Config = require './config'
Authorized = require './authorized'

module.exports =
class Permissions
  @check: (resp) ->
    return unless resp[0]
    return unless resp[0].statusCode == 401

    @report(resp[0])

  @report: (resp) ->
    Log = require './log'
    Log.stop()

    switch resp.body.type
      when 'user-unauthorized'
        Log.p Color.redYellow('You need to log in for that.')
        Log.p("Type #{Color.violet('closeheat login')} to do it swiftly.")
      when 'github-unauthorized'
        Log.error('GitHub not authorized')
        Log.innerError "We cannot set you up for deployment because you did not authorize GitHub.", false
        Log.br()
        Log.innerError "Visit #{Urls.authorizeGitHub()} and rerun the command."
      else
        Log.error("Authorization failed - it shouldn't fail like that though.")
        Log.error("Shoot an email to support@closeheat.com and we'll figure it out.")

    process.exit()
