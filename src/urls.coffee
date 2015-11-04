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
    global.API_URL
    # 'http://api.closeheat.com'
    # 'http://10.30.0.1:4000/api'

  @appsIndex: ->
    "#{@api()}/apps"

  @suggestSlug: ->
    "#{@api()}/suggest/slug"

  @publish: ->
    "#{@api()}/publish"

  @findApp: ->
    "#{@api()}/apps/find"

  @buildForCLI: (slug) ->
    "#{@api()}/apps/#{slug}/builds/for_cli"

  @currentUser: ->
    "#{@api()}/users/me"

  @authorizeGitHub: ->
    "#{@base()}/authorize-github"

  @notifier: ->
    "#{@api()}/cli_notifier"

  @loginInstructions: ->
    "#{@base()}/api/login"
