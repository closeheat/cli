_ = require 'lodash'
chalk = require 'chalk'
Couleurs = require('couleurs')()
opbeat = require('opbeat')(
  organizationId: '1979aa4688cb49b7962c8658bfbc649b'
  appId: 'c19a8164de'
  secretToken: 'f12b94d66534f8cc856401008ddd06b627bc5d53'
  clientLogLevel: 'fatal'
  active: 'true'
)

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

  @innerError: (msg, exit = true) ->
    @line("        #{msg}")
    process.exit() if exit

  @spin: (msg, fn) ->
    Spinner.stop() if @spinning == true

    Spinner.start(msg)
    @spinning = true

  @stop: ->
    if @spinning == true
      Spinner.stop()
      @spinning = false

  @error: (msg, exit = true) ->
    @stop()
    @br()
    @line("#{Color.red('ERROR')} | #{msg}")
    opbeat.captureError(new Error(msg))
    process.exit() if exit

  @backendError: ->
    @error('Backend responded with an error.')

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

  @fromBackendStatus: (status, msg) ->
    if status == 'download_github_repo'
      @backend('Downloading the Github repo.')
    else if status == 'build'
      @backend('Building app.')
    else if status == 'deployed'
      @backend('App is live.')
    else if status == 'error'
      if msg
        @error(msg)
      else
        @backendError()
    else
      @backend('Unknown status.')
