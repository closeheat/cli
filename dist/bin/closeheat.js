#!/usr/bin/env node

var Log, Updater, fs, path, pkg, program, _;

program = require('commander');

_ = require('lodash');

fs = require('fs');

path = require('path');

pkg = require('../../package.json');

Updater = require('../updater');

Log = require('../log');

new Updater().update().then(function() {
  var Server;
  program.version(pkg.version).usage('<keywords>');
  program.command('create [app-name]').description('Creates a new app with clean setup and directory structure.').option('-f, --framework [name]', 'Framework').option('-t, --template [name]', 'Template').option('--javascript [name]', 'Javascript precompiler').option('--html [name]', 'HTML precompiler').option('--css [name]', 'CSS precompiler').option('--tmp [path]', 'The path of temporary directory when creating').option('--dist [path]', 'Path of destination of where to create app dir').option('--no-deploy', 'Do not create GitHub repo and closeheat app').action(function(name, opts) {
    var Creator, includes_template_settings, settings, template_settings;
    Creator = require('../creator');
    settings = _.pick.apply(_, [opts, 'framework', 'template', 'javascript', 'html', 'css', 'dist', 'tmp', 'deploy']);
    settings.name = name;
    Log.logo();
    template_settings = ['framework', 'template', 'javascript', 'html', 'css'];
    includes_template_settings = _.any(_.keys(settings), function(setting) {
      return _.contains(template_settings, setting);
    });
    if (includes_template_settings) {
      return new Creator().createFromSettings(settings);
    } else {
      return new Creator().createFromPrompt(settings);
    }
  });
  program.command('server').description('Runs a server which builds and LiveReloads your app.').option('--ip [ip]', 'IP to run LiveReload on (default - localhost)').option('-p, --port [port]', 'Port to run server on (default - 4000)').action(function(opts) {
    var Server;
    Server = require('../server');
    return new Server().start(opts);
  });
  program.command('deploy').description('Deploys your app to closeheat.com via GitHub.').action(function() {
    var Deployer;
    Deployer = require('../deployer');
    Log.logo();
    return new Deployer().deploy();
  });
  program.command('log').description('Polls the log of the last deployment. Usable: git push origin master && closeheat log').action(function() {
    var DeployLog;
    DeployLog = require('../deploy_log');
    Log.logo();
    return new DeployLog().fromCurrentCommit();
  });
  program.command('open').description('Opens your deployed app in the browser.').action(function() {
    var Deployer;
    Deployer = require('../deployer');
    return new Deployer().open();
  });
  program.command('apps').description('Shows a list of your deployed apps.').action(function() {
    var Apps;
    Apps = require('../apps');
    return new Apps().list();
  });
  program.command('login').option('-t, --token [access-token]', 'Access token from closeheat.com.').description('Log in to closeheat.com with this computer.').action(function(opts) {
    var Authorizer;
    Authorizer = require('../authorizer');
    if (opts.token) {
      return new Authorizer().saveToken(opts.token);
    } else {
      return new Authorizer().login();
    }
  });
  program.command('clone [app-name]').description('Clones the closeheat app files.').action(function(app_name) {
    var Apps, Cloner;
    if (app_name) {
      Cloner = require('../cloner');
      return new Cloner().clone(app_name);
    } else {
      Apps = require('../apps');
      return new Apps().list();
    }
  });
  program.command('transform [type] [language]').description('Transforms files in current dir to other language (Experimental).').action(function(type, language) {
    var Dirs, Transformer, dirs, settings;
    Dirs = require('../dirs');
    Transformer = require('../transformer');
    Log.logo();
    dirs = new Dirs({
      name: 'transforming',
      src: process.cwd(),
      dist: process.cwd()
    });
    settings = {};
    settings[type] = language;
    return new Transformer(dirs).transform(settings).then((function(_this) {
      return function() {
        return console.log('transformed', settings);
      };
    })(this));
  });
  program.command('help').description('Displays this menu.').action(function() {
    Log.logo(0);
    return program.help();
  });
  program.parse(process.argv);
  if (!program.args.length) {
    if (fs.existsSync('index.html') || fs.existsSync('index.jade')) {
      Server = require('../server');
      return new Server().start();
    } else {
      Log.logo(0);
      return program.help();
    }
  }
});
