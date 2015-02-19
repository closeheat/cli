fs = require 'fs'
q = require 'bluebird'
_ = require 'lodash'
path = require 'path'
NPM = require('machinepack-npm')
Log = require './log'
Color = require './color'

module.exports =
class NpmDownloader
  constructor: (@dist, @modules) ->

  downloadAll: =>
    if _.isEmpty(@missing())
      return new q (resolve, reject) ->
        resolve()

    module_downloads = _.map @missing(), (module) =>
      @download(module)

    console.log 'wha'
    console.log module_downloads
    console.log 'up'
    q.when(module_downloads...)

  missing: =>
    _.reject _.uniq(@modules), (module) =>
      fs.existsSync(path.join(@dist, 'node_modules', module))

  download: (module) ->
    new q (resolve, reject) =>
      Log.spin("New require detected. Installing #{Color.orange(module)}.")
      NPM.installPackage({
        name: module
        loglevel: 'silent'
        prefix: @dist
      }).exec({
        error: (err) ->
          Log.stop()
          reject(err)

        success: (name) =>
          Log.stop()
          Log.inner "#{Color.orange(name)} installed."
          resolve()

          # Fill the package.json for exports
          # package_file = {
          #   name: 'closeheat-app'
          #   version: '1.0.0'
          #   dependencies: {},
          #   path: '.',
          # }
          # fs.writeFileSync(path.join(@dist, 'package.json'), JSON.stringify(package_file))
      })
