inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'
inquirer = require 'inquirer'

Urls = require './urls'
UserInput = require './user_input'
Log = require './log'

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
    default_app_name = path.basename(process.cwd())

    new Promise (resolve, reject) ->
      resolve(default_app_name)
    # TODO

  @folder: ->
    _.last(process.cwd().split('/'))

  @rechooseSlug: (opts) =>
    Log.p 'This slug is used'
    @choose(opts)

  @isFree: (slug) ->
    new Promise (resolve, reject) ->
      resolve(true)
      # reject(slug)
