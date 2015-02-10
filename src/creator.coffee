inquirer = require('inquirer')
fs = require('fs.extra')
dirmr = require('dirmr')
Q = require 'q'
_ = require 'lodash'

Prompt = require './prompt'
Dirs = require './dirs'
TemplateDownloader = require './template_downloader'
Transformer = require './transformer'

module.exports =
class Creator
  createFromSettings: (name, settings) ->
    @dirs = new Dirs(name)
    @checkDir()

    defaults =
      framework: 'angular'
      template: 'bootstrap'
      javascript: 'javascript'
      html: 'html'
      css: 'css'

    @createWithSettings(_.defaults(settings, defaults))

  createFromPrompt: (name) ->
    @dirs = new Dirs(name)
    @checkDir()

    inquirer.prompt Prompt.questions, (answers) =>
      console.log answers
      @createWithSettings(answers)

  checkDir: ->
    if fs.existsSync @dirs.target
      throw Error "Directory #{@dirs.target} already exists"

  createWithSettings: (answers) ->
    @dirs.clean()

    @dirs.create().then =>
      downloader = new TemplateDownloader(@dirs, answers.framework, answers.template)

      downloader.download().then =>
        downloader.joinDirs().then =>
          new Transformer(@dirs).transform(answers).then =>
            @moveToTarget().then =>
              @dirs.clean()

              console.log 'Done'

  moveToTarget: ->
    deferred = Q.defer()

    dirmr([@dirs.transformed]).join(@dirs.target).complete (err, result) ->
      console.log err if err
      console.log result if result

      deferred.resolve()

    deferred.promise
