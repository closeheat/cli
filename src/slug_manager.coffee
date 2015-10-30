inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
inquirer = require 'inquirer'

Urls = require './urls'
UserInput = require './user_input'
Log = require './log'

module.exports =
class SlugManager
  @choose: ->
    @suggest()
      .then(UserInput.slug)
      .then(@isFree)
      .catch(@rechooseSlug)

  @suggest: ->
    default_app_name = path.basename(process.cwd())

    new Promise (resolve, reject) ->
      resolve(default_app_name)
    # TODO

  @folder: ->
    _.last(process.cwd().split('/'))

  @rechooseSlug: ->
    Log.p 'This slug is used'
    @choose()

  @isFree: (slug) ->
    new Promise (resolve, reject) ->
      resolve(slug)
      # reject(slug)
