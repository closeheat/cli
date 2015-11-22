program = require 'commander'
homePath = require 'home-path'
path = require 'path'

pkg = require '../../package.json'
Log = require '../log'
Updater = require '../updater'
Notifier = require '../notifier'

setGlobals = (program) ->
  global.API_URL = program.api || 'http://api.closeheat.com'
  global.CONFIG_DIR = program.configDir || path.join(homePath(), '.closeheat')
  global.COLORS = program.colors
  new Updater().update()

program
  .version(pkg.version)
  .usage('<keywords>')
  .option('--api [url]', 'API endpoint. Default: http://api.closeheat.com')
  .option('--config-dir [path]', 'Configuration directory. Default: ~/.closeheat')
  .option('--no-colors', 'Disable colors.')

program
  .command('publish')
  .description('Sets up continuous website delivery from GitHub to closeheat.')
  .action ->
    setGlobals(program)
    Notifier.notify('publish')

    Publisher = require '../publisher'
    new Publisher().start()

program
  .command('deploy')
  .description('Deploys your app to closeheat.com via GitHub.')
  .action ->
    setGlobals(program)
    Notifier.notify('deploy')

    Deployer = require '../deployer'
    new Deployer().deploy()

program
  .command('log')
  .description('Polls the log of the last deployment. Usable: git push origin master && closeheat log')
  .action (a, b) ->
    setGlobals(program)
    Notifier.notify('log')

    DeployLog = require '../deploy_log'
    Log.logo()
    new DeployLog().fromCurrentCommit()

program
  .command('open')
  .description('Opens your deployed app in the browser.')
  .action ->
    setGlobals(program)
    Notifier.notify('open')

    Opener = require '../opener'
    new Opener().open()

program
  .command('list')
  .description('Shows a list of your deployed apps.')
  .action ->
    setGlobals(program)
    Notifier.notify('list')

    List = require '../list'
    new List().show()

program
  .command('login [access-token]')
  .description('Log in to closeheat.com with this computer.')
  .action (token) ->
    setGlobals(program)
    Notifier.notify('login')

    Authorizer = require '../authorizer'
    new Authorizer().login(token)

program
  .command('auth-github')
  .description('Authorize GitHub for your Closeheat account.')
  .action ->
    setGlobals(program)
    Notifier.notify('auth-github')

    GitHubAuthorizer = require '../github_authorizer'
    new GitHubAuthorizer().open()

program
  .command('clone [app-name]')
  .description('Clones the closeheat app files.')
  .action (app_name) ->
    setGlobals(program)
    Notifier.notify('clone', app_name)

    if app_name
      Cloner = require '../cloner'
      new Cloner().clone(app_name)
    else
      List = require '../list'
      new List().show()

program
  .command('help')
  .description('Displays this menu.')
  .action ->
    setGlobals(program)
    Notifier.notify('help')

    Updater = require '../updater'
    new Updater().update().then ->
      Log.logo(0)
      program.help()

program
  .command('postinstall')
  .description('Well, its a command robots run after the install.')
  .action ->
    setGlobals(program)
    Notifier.notify('postinstall')

    Color = require '../color'
    Log.br()
    Log.p('Installation successful.')
    Log.p('------------------------')
    Log.p("Run #{Color.violet('closeheat login')} to authorize your toolkit.")

program
  .command('*')
  .action ->
    setGlobals(program)
    Notifier.notify('wildcard-help')

    Log.logo(0)
    program.help()

program.parse(process.argv)

unless program.args.length
  setGlobals(program)
  Notifier.notify('no-arg-help')

  Log.logo(0)
  program.help()
