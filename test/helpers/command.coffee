Promise = require 'bluebird'
nixt = require 'nixt'
_ = require 'lodash'

closeheat = '../../../dist/bin/closeheat.js'
TestConfig = require './test_config'

module.exports = (command, opts = {}) ->
  nixt_config =
    colors: false

  fillPrompts = (cli) ->
    return cli unless opts.prompts

    _.reduce opts.prompts, (obj, prompt) ->
      obj.on(///#{prompt.question}///).respond("#{prompt.answer}\n")
    , cli

  mockEnv = (cli) ->
    cli
      .env('CLOSEHEAT_TEST', true)

  new Promise (resolve, reject) ->
    test_command = [
      closeheat
      command
      '--api http://localhost:1234'
      "--config-dir #{TestConfig.dir()}"
      '--no-colors'
    ]

    mockEnv(fillPrompts(nixt(nixt_config)))
      .cwd(TestConfig.websiteDir())
      .run(test_command.join(' '))
      .expect((result) ->
        console.log result.stderr if result.stderr
        resolve(result.stdout)
      )
      .end(-> )
