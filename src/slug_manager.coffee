inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
inquirer = require 'inquirer'

Urls = require './urls'
UserInput = require './user_input'
Log = require './log'
Authorized = require './authorized'

module.exports =
class SlugManager
  @choose: (opts) =>
    return validated_slug if opts.slug

    @suggest()
      .then(UserInput.slug)
      .then (slug) =>
         @isFree(slug)
           .then (is_free) =>
             return @rechooseSlug(opts) unless is_free

             _.assign(opts, slug: slug)

  @suggest: ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.suggestSlug(), folder: @folder()).then (resp) ->
        resolve(resp.slug)

  @folder: ->
    _.last(process.cwd().split('/'))

  @rechooseSlug: (opts) =>
    Log.p 'This slug is used'
    @choose(opts)

  @isFree: (slug) ->
    new Promise (resolve, reject) ->
      resolve(true)
      # reject(slug)
