path = require 'path'
pkg = require '../package.json'
fs = require 'fs'

module.exports =
class Config
  @file: ->
    config_path = path.join(@dir(), 'config.json')
    fs.writeFileSync(config_path, JSON.stringify(access_token: '')) unless fs.existsSync(config_path)
    config_path

  @fileContents: ->
    JSON.parse(fs.readFileSync(@file()).toString())

  @dir: ->
    result = global.CONFIG_DIR
    fs.mkdirSync(result) unless fs.existsSync result
    result

  @version: ->
    pkg.version

  @update: (key, val) ->
    contents = @fileContents()
    contents[key] = val
    fs.writeFileSync(@file(), JSON.stringify(contents))
