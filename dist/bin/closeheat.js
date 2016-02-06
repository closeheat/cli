#!/usr/bin/env node

var Log, Notifier, Updater, homePath, path, pkg, program, setGlobals;

program = require('commander');

homePath = require('home-path');

path = require('path');

pkg = require('../../package.json');

Log = require('../log');

Updater = require('../updater');

Notifier = require('../notifier');

setGlobals = function(program) {
  global.API_URL = program.api || 'http://api.closeheat.com';
  global.CONFIG_DIR = program.configDir || path.join(homePath(), '.closeheat');
  global.COLORS = program.colors;
  global.TEST_PUSHER = program.testPusher;
  return new Updater().update();
};

program.version(pkg.version).usage('<keywords>').option('--api [url]', 'API endpoint. Default: http://api.closeheat.com').option('--config-dir [path]', 'Configuration directory. Default: ~/.closeheat').option('--no-colors', 'Disable colors.').option('--test-pusher', 'Use test version of Pusher.');

program.command('publish').description('Sets up continuous website delivery from GitHub to closeheat.').action(function() {
  var Publisher;
  setGlobals(program);
  Notifier.notify('publish');
  Publisher = require('../publisher');
  return new Publisher().start();
});

program.command('log').description('Polls the log of the last deployment. Usable: git push origin master && closeheat log').action(function(a, b) {
  var DeployLog;
  setGlobals(program);
  Notifier.notify('log');
  DeployLog = require('../deploy_log');
  Log.logo();
  return new DeployLog().fromCurrentCommit();
});

program.command('open').description('Opens your deployed app in the browser.').action(function() {
  var Opener;
  setGlobals(program);
  Notifier.notify('open');
  Opener = require('../opener');
  return new Opener().open();
});

program.command('list').description('Shows a list of your deployed apps.').action(function() {
  var List;
  setGlobals(program);
  Notifier.notify('list');
  List = require('../list');
  return new List().show();
});

program.command('login [access-token]').description('Log in to closeheat.com with this computer.').action(function(token) {
  var Authorizer;
  setGlobals(program);
  Notifier.notify('login');
  Authorizer = require('../authorizer');
  return new Authorizer().login(token);
});

program.command('auth-github').description('Authorize GitHub for your Closeheat account.').action(function() {
  var GitHubAuthorizer;
  setGlobals(program);
  Notifier.notify('auth-github');
  GitHubAuthorizer = require('../github_authorizer');
  return new GitHubAuthorizer().open();
});

program.command('clone [app-name]').description('Clones the closeheat app files.').action(function(app_name) {
  var Cloner, List;
  setGlobals(program);
  Notifier.notify('clone', app_name);
  if (app_name) {
    Cloner = require('../cloner');
    return new Cloner().clone(app_name);
  } else {
    List = require('../list');
    return new List().show();
  }
});

program.command('help').description('Displays this menu.').action(function() {
  setGlobals(program);
  Notifier.notify('help');
  Updater = require('../updater');
  return new Updater().update().then(function() {
    Log.logo(0);
    return program.help();
  });
});

program.command('postinstall').description('Well, its a command robots run after the install.').action(function() {
  var Color;
  setGlobals(program);
  Notifier.notify('postinstall');
  Color = require('../color');
  Log.br();
  Log.p('Installation successful.');
  Log.p('------------------------');
  return Log.p("Run " + (Color.violet('closeheat login')) + " to authorize your toolkit.");
});

program.command('*').action(function() {
  setGlobals(program);
  Notifier.notify('wildcard-help');
  Log.logo(0);
  return program.help();
});

program.parse(process.argv);

if (!program.args.length) {
  setGlobals(program);
  Notifier.notify('no-arg-help');
  Log.logo(0);
  program.help();
}
