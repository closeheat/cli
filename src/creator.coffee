inquirer = require 'inquirer'
fs = require 'fs.extra'
dirmr = require 'dirmr'
gulp = require 'gulp'
path = require 'path'
Promise = require 'bluebird'
_ = require 'lodash'

Prompt = require './prompt'
Dirs = require './dirs'
TemplateDownloader = require './template_downloader'
Transformer = require './transformer'
Pusher = require './pusher'
Authorizer = require './authorizer'

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
      @createWithSettings(_.defaults(answers, settings)).catch (err) ->
        console.log err

  checkDir: ->
    if fs.existsSync @dirs.target
      Log.error "Directory #{@dirs.target} already exists"

  createWithSettings: (answers) ->
    Log.br()
    Log.spin('Downloading templates and creating app structure.')

    @dirs.clean()

    @dirs.create().then(=>
      downloader = new TemplateDownloader(@dirs, answers.template, answers.framework)

      downloader.download().then =>
        downloader.merge().then =>
          new Transformer(@dirs).transform(answers).then =>
            @moveToTarget().then =>
              @moveOther(answers).then =>
                @dirs.clean()

                Log.stop()
                Log.inner("App folder created at #{@dirs.target}.")

                return unless answers.deploy

                Log.br()
                Log.doneLine 'Setting up deployment.'
                new Pusher(answers.name, @dirs.target).push().then =>
                  Log.p "Run app server with:"
                  Log.code [
                    "cd #{answers.name}"
                    "closeheat"
                  ]
    ).catch (e) ->
      Log.error(e)

  moveToTarget: ->
    new Promise (resolve, reject) =>
      dirmr([@dirs.transformed]).join(@dirs.target).complete (err, result) ->
        return reject(err) if err

        resolve()

  moveOther: (answers) ->
    new Promise (resolve, reject) =>
      gulp
        .src(path.join(@dirs.whole, "**/*.jade"))
        .pipe(gulp.dest(@dirs.target).on('error', reject))
        .on('error', reject)
        .on('end', resolve)
