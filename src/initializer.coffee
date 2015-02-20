module.exports =
class Initializer
  init: ->
    deferred = Q.defer()

    git.init (err) ->
      throw err if err

      deferred.resolve()

    deferred.promise
