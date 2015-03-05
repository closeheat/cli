program = require 'commander'
_ = require 'lodash'
fs = require 'fs'
path = require 'path'

pkg = require '../../package.json'
Log = require '../log'

program
  .version(pkg.version)
  .usage('<keywords>')

program
  .command('create [app-name]')
  .description('Creates a new app with clean setup and directory structure.')
  .option('-f, --framework [name]', 'Framework')
  .option('-t, --template [name]', 'Template')
  .option('--javascript [name]', 'Javascript precompiler')
  .option('--html [name]', 'HTML precompiler')
  .option('--css [name]', 'CSS precompiler')
  .option('--tmp [path]', 'The path of temporary directory when creating')
  .option('--dist [path]', 'Path of destination of where to create app dir')
  .option('--no-deploy', 'Do not create GitHub repo and closeheat app')
  .action (name, opts) ->
    Creator = require '../creator'

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
        'deploy'
      ]...
    )

    settings.name = name

    Log.logo()

    template_settings = [
      'framework'
      'template'
      'javascript'
      'html'
      'css'
    ]

    includes_template_settings = _.any _.keys(settings), (setting) ->
      _.contains(template_settings, setting)

    if includes_template_settings
      new Creator().createFromSettings(settings)
    else
      new Creator().createFromPrompt(settings)

program
  .command('server')
  .description('Runs a server which builds and LiveReloads your app.')
  .option('--ip [ip]', 'IP to run LiveReload on (default - localhost)')
  .option('-p, --port [port]', 'Port to run server on (default - 4000)')
  .action (opts) ->
    Updater = require '../updater'
    new Updater().update().then ->
      Server = require '../server'
      new Server().start(opts)

program
  .command('deploy')
  .description('Deploys your app to closeheat.com via GitHub.')
  .action ->
    Deployer = require '../deployer'

    Log.logo()
    new Deployer().deploy()

program
  .command('log')
  .description('Polls the log of the last deployment. Usable: git push origin master && closeheat log')
  .action ->
    DeployLog = require '../deploy_log'

    Log.logo()
    new DeployLog().fromCurrentCommit()

program
  .command('open')
  .description('Opens your deployed app in the browser.')
  .action ->
    Deployer = require '../deployer'

    new Deployer().open()

program
  .command('apps')
  .description('Shows a list of your deployed apps.')
  .action ->
    Updater = require '../updater'
    new Updater().update().then ->
      Apps = require '../apps'

      new Apps().list()

program
  .command('login')
  .option('-t, --token [access-token]', 'Access token from closeheat.com.')
  .description('Log in to closeheat.com with this computer.')
  .action (opts) ->
    Authorizer = require '../authorizer'

    if opts.token
      new Authorizer().saveToken(opts.token)
    else
      new Authorizer().login()

program
  .command('clone [app-name]')
  .description('Clones the closeheat app files.')
  .action (app_name) ->
    if app_name
      Cloner = require '../cloner'
      new Cloner().clone(app_name)
    else
      Apps = require '../apps'
      new Apps().list()

program
  .command('transform [type] [language]')
  .description('Transforms files in current dir to other language (Experimental).')
  .action (type, language) ->
    Dirs = require '../dirs'
    Transformer = require '../transformer'

    Log.logo()
    dirs = new Dirs(name: 'transforming', src: process.cwd(), dist: process.cwd())

    settings = {}
    settings[type] = language

    new Transformer(dirs).transform(settings).then =>
      console.log('transformed', settings)

program
  .command('help')
  .description('Displays this menu.')
  .action ->
    Updater = require '../updater'
    new Updater().update().then ->
      Log.logo(0)
      program.help()

program
  .command('postinstall')
  .description('This is run after the install for easy instructions.')
  .action ->
    Color = require '../color'
    Log.br()
    Log.p('Installation successful.')
    Log.p('------------------------')
    Log.p("Run #{Color.violet('closeheat apps')} command for the list of your apps.")

program.parse(process.argv)

unless program.args.length
  if fs.existsSync('index.html') || fs.existsSync('index.jade')
    Server = require '../server'
    new Server().start()
  else
    Log.logo(0)
    program.help()
