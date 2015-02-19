pictureTube = require 'picture-tube'
path = require 'path'
fs = require 'fs'
bar = require('terminal-bar')
images = require('ascii-images')
_ = require('lodash')
chalk = require 'chalk'
colors = require('ansi-256-colors')
c256 = require("colors-256")()
Couleurs = require("couleurs")()

Spinner = require './spinner'

module.exports =
class Log
  @logo: ->
    # tube = pictureTube(cols: 5)
    # tube.pipe(process.stdout)
    # logo_path = path.resolve(__dirname, './img/full.png')
    # fs.createReadStream(logo_path).pipe(tube)
    block_colours = [
      '#FFBB5D'
      '#FF6664'
      '#F8006C'
      '#3590F3'
    ]

    blocks = _.map block_colours, (hex) ->
      Couleurs.bg(' ', hex)
    @line blocks.join('') + blocks.reverse().join('')
    @line()

  @center: (text) ->
    total = _.min([process.stdout.columns, 80])
    start = total / 2 - text.length

    @line()
    @line("#{_.repeat(' ', start)}#{text}")

  @line: (text = '') ->
    console.log(text)

  @br: (times = 1) ->
    _.times times, =>
      @line()

  @inner: (msg) ->
    @line("  #{msg}")

  @spin: (msg, fn) ->
    Spinner.start(msg)

  @spinStop: ->
    Spinner.stop()
