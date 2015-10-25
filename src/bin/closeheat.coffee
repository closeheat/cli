program = require 'commander'

pkg = require '../../package.json'
Log = require '../log'

program
  .version(pkg.version)
  .usage('<keywords>')
  .option('--api [url]', 'API endpoint. Default: http://api.closeheat.com')

program
  .command('deploy')
  .description('Deploys your app to closeheat.com via GitHub.')
  .action ->
    console.log arguments
    Deployer = require '../deployer'

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
  .command('list')
  .description('Shows a list of your deployed apps.')
  .action ->
    Updater = require '../updater'

    new Updater().update().then ->
      List = require '../list'

      new List().show()

program
  .command('login [access-token]')
  .description('Log in to closeheat.com with this computer.')
  .action (token) ->
    Authorizer = require '../authorizer'
    new Authorizer().login(token)

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
    Log.p("Run #{Color.violet('closeheat list')} command for the list of your apps.")

program
  .command('*')
  .action ->
    Log.logo(0)
    program.help()

program.parse(process.argv)

unless program.args.length
  Log.logo(0)
  program.help()
