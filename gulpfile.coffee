gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
fs = require 'fs'
mocha = require 'gulp-mocha'
watch = require 'gulp-watch'
insert = require 'gulp-insert'

gulp.task 'default', ['coffee', 'img']

gulp.task 'watch', ->
  gulp.watch('./src/**/*.coffee', ['default'])
  gulp.watch('./test/fixtures/**/*.coffee', ['default'])

gulp.task 'img', ->
  gulp
    .src('./src/**/*.png')
    .pipe gulp.dest('./dist/')

gulp.task 'coffee', ->
  gulp
    .src('./src/*.coffee')
    .pipe(coffee(bare: true)
      .on('error', gutil.log))
    .pipe gulp.dest('./dist')

  gulp
    .src('./src/bin/closeheat.coffee')
    .pipe(coffee(bare: true)
      .on('error', gutil.log))
    .pipe(insert.prepend('#!/usr/bin/env node\n\n'))
    .pipe gulp.dest('./dist/bin')

  gulp
    .src('./test/fixtures/git/src/*.coffee')
    .pipe(coffee(bare: true)
      .on('error', gutil.log))
    .pipe gulp.dest('./test/fixtures/git/dist')

gulp.task 'test', ->
  gulp
    .src('test/*.coffee', read: false)
    .pipe(mocha())
