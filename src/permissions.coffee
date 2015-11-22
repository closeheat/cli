Urls = require './urls'
Color = require './color'

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
        Log.p Color.redYellow('You need to authorize GitHub for that.')
        Log.br()
        Log.p("Type #{Color.violet('closeheat auth-github')} to do it.")
        Log.p 'And rerun your last command aftewards.'
      else
        Log.error("Authorization failed - it shouldn't fail like that though.")
        Log.error("Shoot an email to support@closeheat.com and we'll figure it out.")

    process.exit()
