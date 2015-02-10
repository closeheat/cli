program = require 'commander'
_ = require 'lodash'

Creator = require '../creator'
Server = require '../server'

program
  .version('0.0.1')
  .usage('<keywords>')

program
  .command('create [name]')
  .alias('new')
  .description('creates a new app with clean setup and directory structure')
  .option('-f, --framework [name]', 'Framework')
  .option('-t, --template [name]', 'Template')
  .option('--javascript [name]', 'Javascript precompiler')
  .option('--html [name]', 'HTML precompiler')
  .option('--css [name]', 'CSS precompiler')
  .action (name, opts) ->
    settings = _.pick(opts, 'framework', 'template', 'javascript', 'html', 'css')

    if _.isEmpty(settings)
      new Creator().createFromPrompt(name)
    else
      new Creator().createFromSettings(name, settings)

program
  .command('server')
  .action ->
    new Server().start()

program.parse(process.argv)

return program.help() unless program.args.length
