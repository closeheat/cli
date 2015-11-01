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

    opts.qs = _.merge(opts.form || {}, api_token: @token())
    opts.headers = { 'X-CLI-Version': pkg.version }
    request opts

  @post: (url, data = {}) ->
    @validateUrl(url)

    new Promise (resolve, reject) =>
      @request(url: url, form: data, json: true, method: 'post').then((resp) ->
        resolve(resp[0].body)
      ).catch (err) ->
        Log.p(err)
        process.exit()

  @get: (url) ->
    @validateUrl(url)

    new Promise (resolve, reject) =>
      @request(url: url, json: true, method: 'get').then((resp) ->
        resolve(resp[0].body)
      ).catch (err) ->
        Log.p(err)
        process.exit()

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
