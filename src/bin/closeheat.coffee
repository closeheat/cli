program = require 'commander'
_ = require 'lodash'
fs = require 'fs'
path = require 'path'

Creator = require '../creator'
Server = require '../server'
Initializer = require '../initializer'
Deployer = require '../deployer'
Apps = require '../apps'
Authorizer = require '../authorizer'
Cloner = require '../cloner'
Log = require '../log'

program
  .version('0.7.2')
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

    Log.logo()

    if _.isEmpty(_.omit(settings, 'name'))
      new Creator().createFromPrompt(settings)
    else
      new Creator().createFromSettings(settings)

program
  .command('server')
  .description('Runs a server which builds and LiveReloads your app.')
  .option('--ip [ip]', 'IP to run LiveReload on (default - localhost)')
  .option('-p, --port [port]', 'Port to run server on (default - 4000)')
  .action (opts) ->
    new Server().start(opts)

program
  .command('deploy')
  .description('Deploys your app to closeheat.com via Github.')
  .action ->
    Log.logo()

    new Deployer().deploy()

program
  .command('apps')
  .description('Shows a list of your deployed apps.')
  .action ->
    new Apps().list()

program
  .command('login')
  .option('-t, --token [access-token]', 'Access token from closeheat.com.')
  .description('Changes the closeheat.com access token on your computer.')
  .action (opts) ->
    if opts.token
      new Authorizer().saveToken(opts.token)
    else
      new Authorizer().login()

program
  .command('clone [app-name]')
  .description('Clones your apps Github repository.')
  .action (app_name) ->
    new Cloner().clone(app_name)

program
  .command('help')
  .description('Displays this menu.')
  .action ->
    Log.logo(0)
    program.help()

program.parse(process.argv)

unless program.args.length
  if fs.existsSync('index.html') || fs.existsSync('index.jade')
    new Server().start()
  else
    Log.logo(0)
    program.help()

  return
  tube = pictureTube(cols: 5)
  tube.pipe(process.stdout)
  logo_path = path.resolve(__dirname, './img/full.png')
  fs.createReadStream(logo_path).pipe(tube)
