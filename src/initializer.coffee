gulp = require 'gulp'
git = require 'gulp-git'
Q = require 'q'

module.exports =
class Initializer
  init: ->
    deferred = Q.defer()

    git.init (err) ->
      throw err if err

      deferred.resolve()

    deferred.promise
