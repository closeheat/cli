Promise = require 'bluebird'
_ = require 'lodash'
Preprocessor = require './preprocessor'

module.exports =
class Transformer
  constructor: (@dirs) ->
    @preprocessor = new Preprocessor(@dirs)

  transform: (answers) ->
    Promise.all(@jobs(answers))

  jobs: (answers) ->
    result = []

    _.each [answers.html, answers.javascript, answers.css], (tech) =>
      result.push @preprocessor.exec(tech)

    result
