fs = require 'fs'
homePath = require('home-path')

module.exports =
class Authorizer
  login: (access_token) ->
    config = { access_token: access_token }
    fs.writeFileSync(@configFile(), JSON.stringify(config))
    console.log "Access token saved."

  accessToken: ->
    JSON.parse(fs.readFileSync(@configFile()).toString()).access_token

  configFile: ->
    "#{homePath()}/.closeheat/config.json"
