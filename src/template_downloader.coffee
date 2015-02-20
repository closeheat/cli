_ = require 'lodash'
Promise = require 'bluebird'
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
    new Promise (resolve, reject) =>
      ghdownload(
        user: 'closeheat',
        repo: "template-#{template}",
        ref: 'master',
        @templateDir(template)
      )
      .on('error', reject)
      .on('end', resolve)

  templateDir: (template) ->
    path.join(@dirs.parts, template)

  templateDirs: ->
    _.map @templates, (template) =>
      @templateDir(template)

  joinDirs: ->
    new Promise (resolve, reject) =>
      dirmr(@templateDirs()).join(@dirs.whole).complete (err, result) ->
        return reject(err) if err
        return reject(result) if result

        resolve()
