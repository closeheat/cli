path = require 'path'
homePath = require 'home-path'
fs = require 'fs.extra'
Promise = require 'bluebird'
mkdirp = require('mkdirp')

module.exports =
class Dirs
  constructor: (settings = {}) ->
    @target = path.join(settings.dist || process.cwd(), settings.name)

    tmp_token = '353cleaned5sometime'
    @tmp = settings.tmp || "#{homePath()}/.closeheat/tmp/creations/#{tmp_token}/"

    @parts = path.join(@tmp, 'parts')
    @whole = path.join(@tmp, 'whole')
    @transformed = path.join(@tmp, 'transformed')

  clean: ->
    fs.rmrfSync(@tmp) if fs.existsSync @tmp

  create: ->
    new Promise (resolve, reject) =>
      mkdirp @parts, (parts_error) =>
        mkdirp @whole, (whole_error) =>
          mkdirp @transformed, (transformed_error) ->
            return reject(parts_error) if parts_error
            return reject(whole_error) if whole_error
            return reject(transformed_error) if transformed_error

            resolve()
