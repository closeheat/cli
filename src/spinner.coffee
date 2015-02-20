Log = require './log'

module.exports =
Spinner = do ->
  util = require('util')
  chalk = require('chalk')

  sequence = [
    chalk.blue('-')
    chalk.red('\\')
    chalk.yellow('|')
    chalk.green('/')
  ]

  index = 0
  timer = undefined

  start = (msg = '') ->
    single_spin_ms = 150
    index = 0

    process.stdout.write("#{sequence[index]} #{msg}")

    timer = setInterval((->
      process.stdout.write sequence[index].replace(/./g, "\r")
      index = if index < sequence.length - 1 then index + 1 else 0
      process.stdout.write sequence[index]
    ), single_spin_ms)

  stop = ->
    clearInterval timer

    # remove spinner
    process.stdout.write sequence[index].replace(/./g, "\r")
    # add a colored dash
    console.log chalk.blue('-')

  {
    start: start
    stop: stop
  }
