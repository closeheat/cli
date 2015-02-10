_ = require 'lodash'
Q = require 'q'
path = require 'path'
ghdownload = require('github-download')
dirmr = require('dirmr')

module.exports =
class TemplateDownloader
  constructor: (@dirs, @templates...) ->

  download: ->
    @downloadFromGithub(@templates[0]).then =>
      @downloadFromGithub(@templates[1])

#     Q.when(@downloadMultipleFromGithub()...).all()
#   downloadMultipleFromGithub: ->
#     _.map @templates, (template) =>
#       @downloadFromGithub(template)

  downloadFromGithub: (template) ->
    deferred = Q.defer()

    ghdownload(
      user: 'closeheat',
      repo: "template-#{template}",
      ref: 'master',
      @templateDir(template)
    )
    .on 'error', (err) ->
      console.log('ERROR: ', err)
    .on 'end', ->
      deferred.resolve()

    deferred.promise

  templateDir: (template) ->
    path.join(@dirs.parts, template)

  templateDirs: ->
    _.map @templates, (template) =>
      @templateDir(template)

  joinDirs: ->
    deferred = Q.defer()

    dirmr(@templateDirs()).join(@dirs.whole).complete (err, result) ->
      console.log('ERROR: ', err) if err
      console.log('ERROR: ', result) if result

      deferred.resolve()

    deferred.promise
