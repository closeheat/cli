path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
Promise = require 'bluebird'
Git = require('git-wrapper')

TestConfig = require('./test_config')

module.exports =
class TestGit
  @exec: ->
    Promise.promisify(new Git().exec)

  @init: ->
    rimraf.sync(TestConfig.websiteDir())
    fs.mkdirSync(TestConfig.websiteDir())

    @exec "-C '#{TestConfig.websiteDir()}' init"

  @createFile: =>
    fs.writeFileSync(path.join(TestConfig.websiteDir(), 'test-file.txt'), 'Testing')

  @addAll: =>
    @exec "-C '#{TestConfig.websiteDir()}' add ."

  @commit: =>
    @exec "-C '#{TestConfig.websiteDir()}' commit -m 'Testing commit message'"

  @exec: (args...) =>
    new Promise (resolve, reject) =>
      new Git().exec args..., (err, resp) ->
        reject(err) if err
        resolve(resp)

  @addRemote: (name = 'origin', url = 'git@github.com:example-org/example-repo.git') =>
    @exec "-C '#{TestConfig.websiteDir()}' remote", ['add', name, url]
