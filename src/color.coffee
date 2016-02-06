Couleurs = require('couleurs')()
chalk = require 'chalk'

module.exports =
class Color
  ORANGE = '#FFBB5D'
  VIOLET = '#3590F3'
  RED = '#F8006C'
  RED_YELLOW = '#FF6664'

  @orange: (msg) ->
    return msg unless global.COLORS
    Couleurs.fg(msg, ORANGE)

  @red: (msg) ->
    return msg unless global.COLORS
    Couleurs.fg(msg, RED)

  @redYellow: (msg) ->
    return msg unless global.COLORS
    Couleurs.fg(msg, RED_YELLOW)

  @violet: (msg) ->
    return msg unless global.COLORS
    Couleurs.fg(msg, VIOLET)

  @bare: (msg) ->
    return msg unless global.COLORS
    chalk.stripColor(msg)
