Urls = require './urls'
Authorized = require './authorized'
Promise= require 'bluebird'

module.exports =
class User
  @get: ->
    new Promise (resolve, reject) ->
      Authorized.get(Urls.currentUser()).then (resp) ->
        resolve(resp.user)
