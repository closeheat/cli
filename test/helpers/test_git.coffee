_ = require 'lodash'

module.exports =
class TestGit
  exec: (cmd, args..., cb) ->
    pretty_cmd = [
      'git'
      cmd
      @prettyArgs(args)
    ]

    console.log "\nTEST: Executing '#{pretty_cmd.join(' ')}'"

    if @[_.camelCase(cmd)]
      @[_.camelCase(cmd)](args, cb)
    else
      cb(null, null)

  prettyArgs: (all_args) ->
    result = _.map all_args, (args) ->
      if _.isArray(args)
        args.join(' ')
      else if _.isPlainObject(args)
        _.map(args, (v, k) -> "#{k}: #{v}").join(' ')
      else
        args.toString()

    result.join(' ')

  remote: (args, cb) ->
    cb null,
      """
      heroku       git://github.com/other-org/other-repo.git (fetch)
      heroku        git://github.com/other-org/other-repo.git (push)
      origin  git@github.com:example-org/example-repo.git (fetch)
      origin  git@github.com:example-org/example-repo.git (push)
      """

  symbolicRef: (args, cb) ->
    cb(null, 'example-branch')
