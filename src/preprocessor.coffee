Promise = require 'bluebird'
callback = require 'gulp-callback'
gulp = require 'gulp'
gutil = require 'gulp-util'
cssScss = require 'gulp-css-scss'
path = require 'path'
js2coffee = require 'gulp-js2coffee'
gulpif = require 'gulp-if'
html2jade = require 'html2jade'
through = require 'through2'
marked = require 'marked'
markdown = require 'gulp-markdown'

Log = require './log'

module.exports =
class Preprocessor
  constructor: (@dirs) ->

  ext: (tech) ->
    EXTENTIONS =
      coffeescript: 'coffee'
      javascript: 'js'
      html: 'html'
      jade: 'jade'
      css: 'css'
      scss: 'scss'
      markdown: 'md'
      jsx: 'jsx'

    EXTENTIONS[tech]

  inverted: (tech) ->
    PAIRS =
      coffeescript: 'javascript'
      jade: 'html'
      scss: 'css'
      markdown: 'html'

    PAIRS[tech]

  sourceFor: (tech) ->
    @ext(@inverted(tech) || tech)

  preprocessorFor: (tech) ->
    PREPROCESSORS =
      coffeescript: -> js2coffee()
      jade: => @jade(nspaces: 2)
      scss: -> cssScss()
      markdown: -> markdown()

    PREPROCESSORS[tech] || -> callback(-> 'no preprocessor')

  exec: (tech) ->
    new Promise (resolve, reject) =>
      gulp
        .src(path.join(@dirs.whole, "**/*.#{@sourceFor(tech)}"))
        .pipe(gulpif(@notMinimized, @preprocessorFor(tech)()))
        .pipe(gulp.dest(@dirs.transformed).on('error', reject))
        .on('error', reject)
        .on('end', resolve)

  notMinimized: (file) ->
    !file.path.match(/\.min\./)

  jade: (options) ->
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
