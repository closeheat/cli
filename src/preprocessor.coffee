Q = require 'q'
callback = require 'gulp-callback'
gulp = require('gulp')
gutil = require 'gulp-util'
cssScss = require('gulp-css-scss')
path = require 'path'
js2coffee = require('gulp-js2coffee')
gulpif = require('gulp-if')

html2jade = require('html2jade')
through = require('through2')

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

    EXTENTIONS[tech]

  inverted: (tech) ->
    PAIRS =
      coffeescript: 'javascript'
      jade: 'html'
      scss: 'css'

    PAIRS[tech]

  sourceFor: (tech) ->
    @ext(@inverted(tech) || tech)

  preprocessorFor: (tech) ->
    PREPROCESSORS =
      coffeescript: -> js2coffee()
      jade: => @jade(nspaces: 2)
      scss: -> cssScss()

    PREPROCESSORS[tech] || -> callback(-> 'no preprocessor')

  exec: (tech) ->
    deferred = Q.defer()

    gulp
      .src(path.join(@dirs.whole, "**/*.#{@sourceFor(tech)}"))
      .pipe(gulpif(@notMinimized, @preprocessorFor(tech)()))
      .pipe(gulp.dest(@dirs.transformed).on('error', gutil.log))
      .pipe(callback(-> deferred.resolve()))

    deferred.promise

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
