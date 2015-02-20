inquirer = require('inquirer')
fs = require('fs.extra')
dirmr = require('dirmr')
Q = require 'q'
_ = require 'lodash'

Prompt = require './prompt'
Dirs = require './dirs'
TemplateDownloader = require './template_downloader'
Transformer = require './transformer'
Pusher = require './pusher'

Log = require './log'
Color = require './color'

module.exports =
class Creator
  createFromSettings: (settings) ->
    @dirs = new Dirs(settings)
    @checkDir()

    defaults =
      framework: 'angular'
      template: 'bootstrap'
      javascript: 'javascript'
      html: 'html'
      css: 'css'

    @createWithSettings(_.defaults(settings, defaults))

  createFromPrompt: (settings) ->
    @dirs = new Dirs(settings)
    @checkDir()

    inquirer.prompt Prompt.questions, (answers) =>
      @createWithSettings(_.defaults(answers, settings))

  checkDir: ->
    if fs.existsSync @dirs.target
      throw Error "Directory #{@dirs.target} already exists"

  createWithSettings: (answers) ->
    Log.br()
    Log.spin('Downloading templates and creating app structure.')

    @dirs.clean()

    @dirs.create().then =>
      downloader = new TemplateDownloader(@dirs, answers.framework, answers.template)

      downloader.download().then =>
        downloader.joinDirs().then =>
          new Transformer(@dirs).transform(answers).then =>
            @moveToTarget().then =>
              @dirs.clean()

              Log.stop()
              Log.inner("App folder created at #{@dirs.target}.")
              Log.br()

              Log.spin 'Setting up deployment.'
              Log.stop()
              new Pusher(answers.name, @dirs.target).push().then =>
                Log.br()
                Log.p "The app #{Color.violet(answers.name)} has been created."
                Log.br()
                Log.p "Run app server with:"
                Log.code [
                  "cd #{answers.name}"
                  "closeheat"
                ]

  moveToTarget: ->
    deferred = Q.defer()

    dirmr([@dirs.transformed]).join(@dirs.target).complete (err, result) ->
      console.log err if err
      console.log result if result

      deferred.resolve()

    deferred.promise
