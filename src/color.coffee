Couleurs = require('couleurs')()
chalk = require 'chalk'

module.exports =
class Color
  ORANGE = '#FFBB5D'
  VIOLET = '#3590F3'
  RED = '#F8006C'
  RED_YELLOW = '#FF6664'

  @orange: (msg) ->
    Couleurs.fg(msg, ORANGE)

  @red: (msg) ->
    Couleurs.fg(msg, RED)

  @redYellow: (msg) ->
    Couleurs.fg(msg, RED_YELLOW)

  @violet: (msg) ->
    Couleurs.fg(msg, VIOLET)

  @bare: (msg) ->
    chalk.stripColor(msg)
