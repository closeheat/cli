Promise = require 'bluebird'
nixt = require 'nixt'
_ = require 'lodash'

closeheat = './dist/bin/closeheat.js'
TestConfig = require './test_config'

module.exports = (command, prompts) ->
  opts =
    colors: false

  fillPrompts = (cli) ->
    return cli unless prompts

    _.reduce prompts, (obj, prompt) ->
      obj.on(///#{prompt.question}///).respond("#{prompt.answer}\n")
    , cli

  new Promise (resolve, reject) ->
    test_command = [
      closeheat
      command
      '--api http://localhost:1234'
      "--config-dir #{TestConfig.dir()}"
      '--no-colors'
    ]

    fillPrompts(nixt(opts))
      .env('CLOSEHEAT_TEST', true)
      .run(test_command.join(' '))
      .expect((result) ->
        resolve(result.stdout)
      )
      .end(-> )
