path = require 'path'
fs = require 'fs'

module.exports =
class TestConfig
  @init: ->
    global.CONFIG_DIR = @dir()

  @dir: ->
    path.join(process.cwd(), 'test', 'fixtures', 'home', '.closeheat')

  @file: ->
    path.join(@dir(), 'config.json')

  @rm: ->
    return unless fs.existsSync(@file())
    fs.unlinkSync(@file())
