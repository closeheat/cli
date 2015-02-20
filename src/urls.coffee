module.exports =
class Urls
  @appData: (app_name) ->
    "#{@appsIndex()}/#{app_name}"

  @base: ->
    # 'http://staging.closeheat.com'
    'http://app.closeheat.com'
    # 'http://10.30.0.1:4000/api'

  @api: ->
    # 'http://staging.closeheat.com/api'
    'http://api.closeheat.com'
    # 'http://10.30.0.1:4000/api'

  @appsIndex: ->
    "#{@api()}/apps"

  @createApp: ->
    "#{@api()}/apps"

  @currentUserInfo: ->
    "#{@api()}/users/me"

  @getToken: ->
    "#{@api()}/users/token"

  @authorizeGithub: ->
    "#{@base()}/authorize-github"
