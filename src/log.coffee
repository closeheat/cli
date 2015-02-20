_ = require 'lodash'
chalk = require 'chalk'
Couleurs = require("couleurs")()

Spinner = require './spinner'
Color = require './color'

module.exports =
class Log
  @logo: (br = 1) ->
    block_colours = [
      '#FFBB5D'
      '#FF6664'
      '#F8006C'
      '#3590F3'
    ]

    blocks = _.map block_colours, (hex) ->
      Couleurs.bg(' ', hex)
    @line blocks.join('') + blocks.reverse().join('')
    @br(br)

  @center: (text) ->
    total = _.min([process.stdout.columns, 80])
    start = total / 2 - text.length

    @line()
    @line("#{_.repeat(' ', start)}#{text}")

  @line: (text = '') ->
    console.log(text)

  @p: (text = '') ->
    console.log(text)

  @br: (times = 1) ->
    _.times times, =>
      @line()

  @inner: (msg) ->
    @line("  #{msg}")

  @spin: (msg, fn) ->
    Spinner.stop() if @spinning == true

    Spinner.start(msg)
    @spinning = true

  @stop: ->
    if @spinning == true
      Spinner.stop()
      @spinning = false

  @error: (msg) ->
    @stop()
    @line("#{Color.red('ERROR')} | #{msg}")

  @code: (msg) ->
    @br()

    if _.isArray(msg)
      _.each msg, (m) =>
        @inner(Color.violet(m))
    else
      @inner(Color.violet(msg))

  @secondaryCode: (msg) ->
    @br()

    if _.isArray(msg)
      _.each msg, (m) =>
        @inner(m)
    else
      @inner(msg)

  @doneLine: (msg) ->
    @p "#{chalk.blue('-')} #{msg}"

  @backend: (msg) ->
    Log.inner("#{Color.orange('closeheat')} | #{msg}")
