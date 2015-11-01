Urls = require './urls'
Authorized = require './authorized'

module.exports =
class User
  @get: ->
    Authorized.get(Urls.currentUser())
