_ = require 'lodash'
Promise = require 'bluebird'
path = require 'path'
ghdownload = require('github-download')
dirmr = require('dirmr')
fs = require 'fs.extra'
gulp = require 'gulp'
inject = require 'gulp-inject'

module.exports =
class TemplateDownloader
  constructor: (@dirs, @template, @framework) ->

  download: ->
    @cleanTemplateDirs()

    @downloadFromGithub(@template).then =>
      @downloadFromGithub(@framework)

  downloadFromGithub: (template) ->
    new Promise (resolve, reject) =>
      return resolve() if fs.existsSync @templateDir(template)

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
    _.map [@template, @framework], (template) =>
      @templateDir(template)

  cleanTemplateDirs: ->
    _.each @templateDirs(), (template) ->
      fs.rmrfSync(template) if fs.existsSync template

  merge: ->
    @joinDirs().then(@injectAssets)

  joinDirs: ->
    new Promise (resolve, reject) =>
      dirmr(@templateDirs()).join(@dirs.whole).complete (err, result) =>
        return reject(err) if err
        return reject(result) if result

        resolve()

  injectAssets: =>
    new Promise (resolve, reject) =>
      paths = gulp.src([
        path.join(@dirs.whole, 'css/**/*.min.css')
        path.join(@dirs.whole, 'css/**/*.css')
        path.join(@dirs.whole, 'js/**/*.min.js')
        path.join(@dirs.whole, 'js/**/*.js')
      ]
      , read: false)

      gulp
        .src(path.join(@dirs.whole, 'index.html'))
        .pipe(inject(paths, relative: true, removeTags: true))
        .pipe(gulp.dest(@dirs.whole))
        .on('error', reject)
        .on('end', resolve)
