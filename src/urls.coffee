module.exports =
class Urls
  @appData: (app_name) ->
    "#{@appsIndex()}/#{app_name}"

  @base: ->
    'http://staging.closeheat.com'
    'http://10.30.0.1:4000'

  @appsIndex: ->
    "#{@base()}/api/apps"

  @createApp: ->
    "#{@base()}/api/apps"

  @currentUserInfo: ->
    "#{@base()}/api/users/me"

  @authorizeGithub: ->
    "#{@base()}/authorize-github"
