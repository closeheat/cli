program = require 'commander'
_ = require 'lodash'
fs = require 'fs.extra'

Creator = require '../creator'
Server = require '../server'
Initializer = require '../initializer'
Deployer = require '../deployer'
Apps = require '../apps'
Authorizer = require '../authorizer'
Cloner = require '../cloner'

program
  .version('0.0.1')
  .usage('<keywords>')

program
  .command('create [app-name]')
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
  .option('--ip [ip]', 'IP to run LiveReload on (default - localhost)')
  .option('-p, --port [port]', 'Port to run server on (default - 4000)')
  .action (opts) ->
    new Server().start(opts)

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
  .command('login [access-token]')
  .action (access_token) ->
    new Authorizer().login(access_token)

program
  .command('clone [app-name]')
  .action (app_name) ->
    new Cloner().clone(app_name)

program
  .command('help')
  .action ->
    program.help()

program.parse(process.argv)

unless program.args.length
  if fs.existsSync('index.html') || fs.existsSync('index.jade')
    new Server().start()
  else
    program.help()

  return
