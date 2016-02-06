open = require 'open'

Log = require './log'
Color = require './color'
Website = require './website'

module.exports =
class Opener
  open: ->
    Website.get().then (website) ->
      unless website.exists
        Log.p("No published website from this folder exists.")
        return Log.p("To publish this folder, type: #{Color.violet('closeheat publish')}")

      Log.p "Opening your website at #{website.url}."
      open(website.url) unless process.env.CLOSEHEAT_TEST
