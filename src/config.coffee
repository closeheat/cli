homePath = require 'home-path'
path = require 'path'
pkg = require '../package.json'
fs = require 'fs'

module.exports =
class Config
  @file: ->
    path.join(@dir(), 'config.json')

  @fileContents: ->
    JSON.parse(fs.readFileSync(@file()).toString())

  @dir: ->
    result = path.join(homePath(), '.closeheat')
    fs.mkdirSync(result) unless fs.existsSync result
    result

  @version: ->
    pkg.version

  @update: (key, val) ->
    contents = @fileContents()
    contents[key] = val
    fs.writeFileSync(@file(), JSON.stringify(contents))
