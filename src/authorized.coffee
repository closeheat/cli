request = require 'request'
_ = require 'lodash'
pkg = require '../package.json'

Authorizer = require './authorizer'
Log = require './log'

module.exports =
class Authorized
  @request: (params...) ->
    [opts, cb] = params
    Log = require './log'
    Log.error("Request opts is not an object: #{opts}") unless _.isPlainObject(opts)
    token_params = @tokenParams(opts, cb)

    if token_params
      opts.qs = _.merge(opts.qs || {}, token_params)
      opts.headers = { 'X-CLI-Version': pkg.version }
      console.log params
      request opts, @loginOnUnauthorized(opts, cb)

  @tokenParams: (opts, cb) ->
    Authorizer = require './authorizer'
    authorizer = new Authorizer()

    api_token = authorizer.accessToken()

    if api_token == 'none' || !api_token
      authorizer.forceLogin(=> @request(opts, cb))
      return false

    api_token: api_token

  @loginOnUnauthorized: (opts, cb) =>
    (err, resp) =>
      Log = require './log'
      Log.error(err) if err
      authorizer = new Authorizer()

      if authorizer.unauthorized(resp)
        authorizer.forceLogin(=> @request(opts, cb))
      else
        cb(err, resp)
