Promise = require 'bluebird'
path = require 'path'
nixt = require 'nixt'

closeheat = './dist/bin/closeheat.js'
TestConfig = require './test_config'

module.exports = (command) ->
  opts =
    colors: false
    newlines: false

  new Promise (resolve, reject) ->
    test_command = "#{closeheat} #{command} --api http://localhost:1234 --config-dir #{TestConfig.dir()} --no-browser"

    nixt(opts)
      .run(test_command)
      .expect((result) ->
        resolve(result.stdout)
      )
      .end(-> )
