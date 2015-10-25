program = require 'commander'
homePath = require 'home-path'
path = require 'path'

pkg = require '../../package.json'
Log = require '../log'

setGlobals = (program) ->
  global.API_URL = program.api || 'http://api.closeheat.com'
  global.CONFIG_DIR = program.configDir || path.join(homePath(), '.closeheat')
  global.BROWSER = program.browser
  global.GIT = program.git

program
  .version(pkg.version)
  .usage('<keywords>')
  .option('--api [url]', 'API endpoint. Default: http://api.closeheat.com')
  .option('--config-dir [path]', 'Configuration directory. Default: ~/.closeheat')
  .option('--no-browser', 'Never launch browser for anything.')
  .option('--no-git', 'Never use git.')

program
  .command('deploy')
  .description('Deploys your app to closeheat.com via GitHub.')
  .action ->
    setGlobals(program)
    Deployer = require '../deployer'

    new Deployer().deploy()

program
  .command('log')
  .description('Polls the log of the last deployment. Usable: git push origin master && closeheat log')
  .action (a, b) ->
    setGlobals(program)
    DeployLog = require '../deploy_log'

    Log.logo()
    new DeployLog().fromCurrentCommit()

program
  .command('open')
  .description('Opens your deployed app in the browser.')
  .action ->
    setGlobals(program)
    Deployer = require '../deployer'

    new Deployer().open()

program
  .command('list')
  .description('Shows a list of your deployed apps.')
  .action ->
    setGlobals(program)
    Updater = require '../updater'

    new Updater().update().then ->
      List = require '../list'

      new List().show()

program
  .command('login [access-token]')
  .description('Log in to closeheat.com with this computer.')
  .action (token) ->
    setGlobals(program)

    Authorizer = require '../authorizer'
    new Authorizer().login(token)

program
  .command('clone [app-name]')
  .description('Clones the closeheat app files.')
  .action (app_name) ->
    setGlobals(program)

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

    Updater = require '../updater'
    new Updater().update().then ->
      Log.logo(0)
      program.help()

program
  .command('postinstall')
  .description('This is run after the install for easy instructions.')
  .action ->
    setGlobals(program)

    Color = require '../color'
    Log.br()
    Log.p('Installation successful.')
    Log.p('------------------------')
    Log.p("Run #{Color.violet('closeheat list')} command for the list of your apps.")

program
  .command('*')
  .action ->
    setGlobals(program)

    Log.logo(0)
    program.help()

program.parse(process.argv)

unless program.args.length
  setGlobals(program)

  Log.logo(0)
  program.help()
