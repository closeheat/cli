fs = require 'fs'
homePath = require('home-path')

module.exports =
class Authorizer
  login: (access_token) ->
    config_file = "#{homePath()}/.closeheat/config.json"
    config = { access_token: access_token }
    fs.writeFileSync(config_file, JSON.stringify(config))
    console.log "Access token saved."
