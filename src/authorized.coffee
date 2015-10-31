Promise = require 'bluebird'
request = Promise.promisify(require('request'))
_ = require 'lodash'
pkg = require '../package.json'

Authorizer = require './authorizer'
Log = require './log'

module.exports =
class Authorized
  @request: (opts) ->
    Log = require './log'
    Log.error("Request opts is not an object: #{opts}") unless _.isPlainObject(opts)
    Log.error('Log in please') unless @token()

    opts.qs = _.merge(opts.qs || {}, api_token: @token())
    opts.headers = { 'X-CLI-Version': pkg.version }
    request opts

  @post: (url, data) ->
    new Promise (resolve, reject) =>
      @request(url: url, qs: data, json: true, method: 'post').then((resp) ->
        resolve(resp[0].body)
      ).catch ->
        console.log 'CATCH'
        reject

  @token: ->
    Authorizer = require './authorizer'
    authorizer = new Authorizer()

    result = authorizer.accessToken()
    return null if result == 'none' || !result

    result
