path = require 'path'
homePath = require('home-path')
fs = require('fs.extra')
Q = require 'q'
mkdirp = require('mkdirp')

module.exports =
class Dirs
  constructor: (app_name) ->
    @target = path.join(process.cwd(), app_name)

    tmp_token = '353cleaned5sometime'
    @tmp = "#{homePath()}/.closeheat/tmp/creations/#{tmp_token}/"

    @parts = path.join(@tmp, 'parts')
    @whole = path.join(@tmp, 'whole')
    @transformed = path.join(@tmp, 'transformed')

  clean: ->
    fs.rmrfSync(@tmp) if fs.existsSync @tmp

  create: ->
    deferred = Q.defer()

    mkdirp @parts, (parts_error) =>
      mkdirp @whole, (whole_error) =>
        mkdirp @transformed, (transformed_error) ->
          console.log if parts_error
          console.log if whole_error
          console.log if transformed_error

          deferred.resolve()

    deferred.promise
