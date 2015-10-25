#!/usr/bin/env node

var Log, homePath, path, pkg, program, setGlobals;

program = require('commander');

homePath = require('home-path');

path = require('path');

pkg = require('../../package.json');

Log = require('../log');

setGlobals = function(program) {
  global.API_URL = program.api || 'http://api.closeheat.com';
  global.CONFIG_DIR = program.configDir || path.join(homePath(), '.closeheat');
  global.BROWSER = program.browser;
  return console.log(program);
};

program.version(pkg.version).usage('<keywords>').option('--api [url]', 'API endpoint. Default: http://api.closeheat.com').option('--config-dir [path]', 'Configuration directory. Default: ~/.closeheat').option('--no-browser', 'Never launch browser for anything.');

program.command('deploy').description('Deploys your app to closeheat.com via GitHub.').action(function() {
  var Deployer;
  setGlobals(program);
  Deployer = require('../deployer');
  return new Deployer().deploy();
});

program.command('log').description('Polls the log of the last deployment. Usable: git push origin master && closeheat log').action(function(a, b) {
  var DeployLog;
  setGlobals(program);
  DeployLog = require('../deploy_log');
  Log.logo();
  return new DeployLog().fromCurrentCommit();
});

program.command('open').description('Opens your deployed app in the browser.').action(function() {
  var Deployer;
  setGlobals(program);
  Deployer = require('../deployer');
  return new Deployer().open();
});

program.command('list').description('Shows a list of your deployed apps.').action(function() {
  var Updater;
  setGlobals(program);
  Updater = require('../updater');
  return new Updater().update().then(function() {
    var List;
    List = require('../list');
    return new List().show();
  });
});

program.command('login [access-token]').description('Log in to closeheat.com with this computer.').action(function(token) {
  var Authorizer;
  setGlobals(program);
  Authorizer = require('../authorizer');
  return new Authorizer().login(token);
});

program.command('clone [app-name]').description('Clones the closeheat app files.').action(function(app_name) {
  var Apps, Cloner;
  setGlobals(program);
  if (app_name) {
    Cloner = require('../cloner');
    return new Cloner().clone(app_name);
  } else {
    Apps = require('../apps');
    return new Apps().list();
  }
});

program.command('help').description('Displays this menu.').action(function() {
  var Updater;
  setGlobals(program);
  Updater = require('../updater');
  return new Updater().update().then(function() {
    Log.logo(0);
    return program.help();
  });
});

program.command('postinstall').description('This is run after the install for easy instructions.').action(function() {
  var Color;
  setGlobals(program);
  Color = require('../color');
  Log.br();
  Log.p('Installation successful.');
  Log.p('------------------------');
  return Log.p("Run " + (Color.violet('closeheat list')) + " command for the list of your apps.");
});

program.command('*').action(function() {
  setGlobals(program);
  Log.logo(0);
  return program.help();
});

program.parse(process.argv);

if (!program.args.length) {
  setGlobals(program);
  Log.logo(0);
  program.help();
}
