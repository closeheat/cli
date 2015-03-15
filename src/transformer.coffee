Promise = require 'bluebird'
_ = require 'lodash'
del = require 'del'

Preprocessor = require './preprocessor'

module.exports =
class Transformer
  constructor: (@dirs) ->
    @preprocessor = new Preprocessor(@dirs)

  transform: (answers) ->
    Promise.all(@jobs(answers))

  remove: (source_type) ->
    new Promise (resolve, reject) =>
      del ["#{@dirs.dist}/**/*.#{source_type}"], (err, paths) ->
        reject(err) if err
        resolve(paths)

  jobs: (answers) ->
    result = []

    answers.javascript = 'jsx' if answers.framework == 'react'
    _.each [answers.html, answers.javascript, answers.css], (tech) =>
      return unless tech

      result.push @preprocessor.exec(tech)

    result
