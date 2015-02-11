gulp = require 'gulp'
git = require 'gulp-git'
q = require 'bluebird'

module.exports =
class Apps
  showList: ->
    console.log 'list'
