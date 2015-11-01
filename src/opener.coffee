open = require 'open'

Log = require './log'
Color = require './color'
Website = require './website'

module.exports =
class Opener
  open: ->
    console.log 'openin'
    # Website.get().then (website) ->
    #   unless website.exists
    #     Log.p("No published website from this folder exists.")
    #     return Log.p("Type closeheat publish to create it.")
    #
    #   Log.p "Opening your website at #{website.url}."
    #   open(website.url) unless process.env.CLOSEHEAT_TEST
