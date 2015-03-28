Urls = require './urls'
Authorizer = require './authorizer'
request = require 'request'
pkg = require '../package.json'

module.exports =
class Notifier
  @notify: (action, app_slug = undefined) ->
    authorizer = new Authorizer

    parameters =
      name: action
      api_token: authorizer.accessToken()
      app_slug: app_slug

    request_options =
      url: Urls.notifier()
      body: JSON.stringify(parameters)
      method: 'post'
      headers:
        'Content-Type': 'application/json'
        'X-CLI-Version': pkg.version

    request request_options
    true
