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

    opts.qs = _.merge(opts.form || {}, api_token: @token())
    opts.headers = { 'X-CLI-Version': pkg.version }

    request(opts).then((resp) =>
      Permissions = require './permissions'
      Permissions.check(resp)

      Errors = require './errors'
      Errors.check(resp)

      resp[0].body

    ).catch (err) ->
      Log.p(err)
      process.exit()

  @post: (url, data = {}) ->
    @validateUrl(url)

    @request(url: url, form: data, json: true, method: 'post')

  @get: (url) ->
    @validateUrl(url)

    @request(url: url, json: true, method: 'get')

  @validateUrl: (url) ->
    return if _.isString(url)

    Log.p("Url #{url} is not a string")
    process.exit()

  @token: ->
    Authorizer = require './authorizer'
    authorizer = new Authorizer()

    result = authorizer.accessToken()
    return null if result == 'none' || !result

    result
