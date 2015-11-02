Promise = require 'bluebird'
_ = require 'lodash'

Urls = require './urls'
UserInput = require './user_input'
Authorized = require './authorized'

module.exports =
class SlugManager
  @choose: (opts) =>
    @suggest()
      .then(UserInput.slug)
      .then (slug) =>
         _.assign(opts, slug: slug)

  @suggest: ->
    new Promise (resolve, reject) =>
      Authorized.post(Urls.suggestSlug(), folder: @folder()).then (resp) ->
        resolve(resp.slug)

  @folder: ->
    _.last(process.cwd().split('/'))
