program = require 'commander'
_ = require 'lodash'

Creator = require '../creator'
Server = require '../server'
Initializer = require '../initializer'
Deployer = require '../deployer'
Apps = require '../apps'
Authorizer = require '../authorizer'

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
  .option('--tmp [path]', 'The path of temporary directory when creating')
  .option('--dist [path]', 'Path of destination of where to create app dir')
  .action (name, opts) ->
    settings = _.pick(
      [
        opts
        'framework'
        'template'
        'javascript'
        'html'
        'css'
        'dist'
        'tmp'
      ]...
    )

    settings.name = name

    if _.isEmpty(_.omit(settings, 'name'))
      new Creator().createFromPrompt(settings)
    else
      new Creator().createFromSettings(settings)

program
  .command('server')
  .action ->
    new Server().start()

program
  .command('init')
  .action ->
    new Initializer().init()

program
  .command('deploy')
  .action ->
    new Deployer().deploy()

program
  .command('apps')
  .action ->
    new Apps().showList()

program
  .command('login [access_token]')
  .action (access_token) ->
    new Authorizer().login(access_token)

program.parse(process.argv)

return program.help() unless program.args.length
