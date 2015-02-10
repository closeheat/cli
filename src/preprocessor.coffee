Q = require 'q'
callback = require 'gulp-callback'
gulp = require('gulp')
gutil = require 'gulp-util'
cssScss = require('gulp-css-scss')
path = require 'path'
js2coffee = require('gulp-js2coffee')

JadePreprocessor = require('./jade_preprocessor')

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
      jade: -> new JadePreprocessor.exec(nspaces: 2)
      scss: -> cssScss()

    PREPROCESSORS[tech] || -> callback(-> 'no preprocessor')

  exec: (tech) ->
    deferred = Q.defer()

    gulp
      .src(path.join(@dirs.whole, "**/*.#{@sourceFor(tech)}"))
      .pipe(@preprocessorFor(tech)())
      .pipe(gulp.dest(@dirs.transformed).on('error', gutil.log))
      .pipe(callback(-> deferred.resolve()))

    deferred.promise
