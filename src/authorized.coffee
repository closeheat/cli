request = require 'request'
_ = require 'lodash'

Authorizer = require './authorizer'
Log = require './log'

module.exports =
class Authorized
  @request: (params...) ->
    [opts, cb] = params
    token_params = @tokenParams(opts, cb)

    if token_params
      opts.qs = _.merge(opts.qs || {}, token_params)
      request opts, @loginOnUnauthorized(opts, cb)

  @tokenParams: (opts, cb) ->
    authorizer = new Authorizer
    api_token = authorizer.accessToken()

    if api_token == 'none' || !api_token
      authorizer.forceLogin(=> @request(opts, cb))
      return false

    api_token: api_token

  @loginOnUnauthorized: (opts, cb) =>
    (err, resp) =>
      Log.error(err) if err
      authorizer = new Authorizer()

      if authorizer.unauthorized(resp)
        authorizer.forceLogin(=> @request(opts, cb))
      else
        cb(err, resp)
