inquirer = require('inquirer')
fs = require('fs.extra')
dirmr = require('dirmr')
Q = require 'q'

Prompt = require './prompt'
Dirs = require './dirs'
TemplateDownloader = require './template_downloader'
Transformer = require './transformer'

module.exports =
class Creator
  create: (name) ->
    @dirs = new Dirs(name)

    if fs.existsSync @dirs.target
      console.log "Directory #{@dirs.target} already exists"
      return

    inquirer.prompt Prompt.questions, (answers) =>
      @createFromSettings(answers)

  createFromSettings: (answers) ->
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
