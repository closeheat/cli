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

  @githubAuthorized: ->
    "#{@api()}/github-authorized"

  @appsIndex: ->
    "#{@api()}/apps"

  @deployedSlug: ->
    "#{@api()}/deploy/slug"

  @suggestSlug: ->
    "#{@api()}/suggest/slug"

  @suggestRepo: ->
    "#{@api()}/suggest/repo"

  @isFreeSlug: ->
    "#{@api()}/free/slug"

  @isFreeRepo: ->
    "#{@api()}/free/slug"

  @publishNewWebsite: ->
    "#{@api()}/deploy/new"

  @setupExistingRepo: ->
    "#{@api()}/deploy/existing"

  @websiteExists: ->
    "#{@api()}/apps/exists"

  @latestBuild: (slug) ->
    "#{@api()}/apps/#{slug}/builds/latest"

  @buildForCLI: (slug) ->
    "#{@api()}/apps/#{slug}/builds/for_cli"

  @createApp: ->
    "#{@api()}/apps"

  @currentUserInfo: ->
    "#{@api()}/users/me"

  @getToken: ->
    "#{@api()}/users/token"

  @authorizeGitHub: ->
    "#{@base()}/authorize-github"

  @notifier: ->
    "#{@api()}/cli_notifier"

  @loginInstructions: ->
    "#{@base()}/api/login"
