pictureTube = require 'picture-tube'
path = require 'path'
fs = require 'fs'
bar = require('terminal-bar')
images = require('ascii-images')
_ = require('lodash')

module.exports =
class Log
  @logo: ->
    tube = pictureTube(cols: 5)
    tube.pipe(process.stdout)
    logo_path = path.resolve(__dirname, './img/full.png')
    fs.createReadStream(logo_path).pipe(tube)
    @center('[ closeheat ]')

  @center: (text) ->
    total = _.min([process.stdout.columns, 80])
    start = total / 2 - text.length

    @line()
    @line("#{_.repeat(' ', start)}#{text}")

  @line: (text = '') ->
    console.log(text)
