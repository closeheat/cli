request = require 'request'
_ = require 'lodash'

Authorizer = require './authorizer'
Log = require './log'

module.exports =
class Authorized
  @request: (params...) ->
    [opts, cb] = params
    opts.qs = _.merge(opts.qs || {}, @tokenParams())
    request opts, @loginOnUnauthorized(opts, cb)

  @tokenParams: ->
    authorizer = new Authorizer
    api_token: authorizer.accessToken()

  @loginOnUnauthorized: (opts, cb) =>
    (err, resp) =>
      Log.error(err) if err
      authorizer = new Authorizer()

      if authorizer.unauthorized(resp)
        authorizer.forceLogin(=> @request(opts, cb))
      else
        cb(err, resp)
