inquirer = require('inquirer')
fs = require('fs.extra')
path = require('path')
ghdownload = require('github-download')
_ = require 'lodash'
Q = require 'q'
homePath = require('home-path')
mkdirp = require('mkdirp')
dirmr = require('dirmr')
ghtml2jade = require('gulp-html2jade')
gulp = require('gulp')
gutil = require 'gulp-util'
html2jade = require('html2jade')
through = require('through2')

module.exports =
class Creator
  create: (name) ->
    @src = process.cwd()
    @tmp_dir = "#{homePath()}/.closeheat/tmp/creations/353cleaned5sometime/"

    inquirer.prompt [
      {
        message: 'Framework to use?'
        name: 'framework'
        type: 'list'
        choices: [
          {
            name: 'Angular.js'
            value: 'angular'
          }
          {
            name: 'React.js'
            value: 'react'
          }
          {
            name: 'Ember.js'
            value: 'ember'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'Template?'
        name: 'template'
        type: 'list'
        choices: [
          {
            name: 'Bootstrap'
            value: 'bootstrap'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'Javascript preprocessor?'
        name: 'javascript'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'CoffeeScript'
            value: 'coffeescript'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'HTML preprocessor?'
        name: 'html'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'Jade'
            value: 'jade'
          }
          {
            name: 'None'
            value: 'none'
          }
        ]
      }
      {
        message: 'CSS preprocessor?'
        name: 'css'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'SCSS'
            value: 'scss'
          }
          {
            name: 'None'
            value: 'none'
          }
        ]
      }
    ], (answers) =>
      @createFromSettings(name, answers)

  createFromSettings: (name, answers) ->
    app_dir = path.join(process.cwd(), name)
    parts_dir = path.join(@tmp_dir, 'parts')
    whole_dir = path.join(@tmp_dir, 'whole')
    transformed_dir = path.join(@tmp_dir, 'transformed')

    if fs.existsSync parts_dir
      fs.rmrfSync(parts_dir)

    if fs.existsSync whole_dir
      fs.rmrfSync(whole_dir)

    mkdirp parts_dir, (err) =>
      mkdirp whole_dir, (err2) =>
        if err or err2
          console.log err
          console.log err2

        framework_dir = path.join(@tmp_dir, 'parts', answers.framework)
        template_dir = path.join(@tmp_dir, 'parts', answers.template)

        @downloadAndAdd(framework_dir, answers.framework).then =>
          @downloadAndAdd(template_dir, answers.template).then =>
            dirmr([template_dir, framework_dir]).join(whole_dir)
            console.log 'merged'
            @transform(answers)

  downloadAndAdd: (tmp, part) ->
    deferred = Q.defer()

    console.log "installing #{part}"
    ghdownload(user: 'closeheat', repo: "template-#{part}", ref: 'master', tmp)
      .on('dir', (dir) ->
        console.log "dir")
      .on 'error', (err) ->
        console.log(err)
      .on 'end', ->
        console.log('donw')
        deferred.resolve(true)

    deferred.promise

  transform: (answers) ->
    whole_dir = path.join(@tmp_dir, 'whole')
    transformed_dir = path.join(@tmp_dir, 'transformed')

    mkdirp transformed_dir, (err) =>
      console.log(err) if err

      gulp
        # .src(path.join(whole_dir, '*/**.html'))
        .src('index.html')
        # .pipe(ghtml2jade(nspaces: 2))
        .pipe(@gulpHtmlToJade(nspaces: 2).on('error', gutil.log))
        .pipe(gulp.dest(transformed_dir).on('error', gutil.log))


  gulpHtmlToJade: (options) ->
    through.obj (file, enc, cb) ->
      if (file.isNull())
        cb(null, file)
        return

      options = options or {}
      html = file.contents.toString()
      html2jade.convertHtml html, options, (err, jade) ->
        file.contents = new Buffer(jade)
        file.path = gutil.replaceExtension(file.path, ".jade")
        cb null, file
