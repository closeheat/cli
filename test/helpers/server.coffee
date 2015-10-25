Promise = require 'bluebird'
path = require 'path'
nixt = require 'nixt'

closeheat = './dist/bin/closeheat.js'
home_path = path.join(process.cwd(), 'test', 'fixtures', 'home')

module.exports = (command) ->
  opts =
    colors: false
    newlines: false

  new Promise (resolve, reject) ->
    nixt(opts)
      .env('HOME', home_path)
      .run("#{closeheat} #{command} --api http://localhost:1234")
      .expect((result) ->
        resolve(result.stdout)
      )
      .end(-> )
