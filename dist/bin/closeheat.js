#!/usr/bin/env node

var Creator, Deployer, Initializer, Server, program, _;

program = require('commander');

_ = require('lodash');

Creator = require('../creator');

Server = require('../server');

Initializer = require('../initializer');

Deployer = require('../deployer');

program.version('0.0.1').usage('<keywords>');

program.command('create [name]').alias('new').description('creates a new app with clean setup and directory structure').option('-f, --framework [name]', 'Framework').option('-t, --template [name]', 'Template').option('--javascript [name]', 'Javascript precompiler').option('--html [name]', 'HTML precompiler').option('--css [name]', 'CSS precompiler').option('--tmp [path]', 'The path of temporary directory when creating').option('--dist [path]', 'Path of destination of where to create app dir').action(function(name, opts) {
  var settings;
  settings = _.pick.apply(_, [opts, 'framework', 'template', 'javascript', 'html', 'css', 'dist', 'tmp']);
  settings.name = name;
  if (_.isEmpty(_.omit(settings, 'name'))) {
    return new Creator().createFromPrompt(settings);
  } else {
    return new Creator().createFromSettings(settings);
  }
});

program.command('server').action(function() {
  return new Server().start();
});

program.command('init').action(function() {
  return new Initializer().init();
});

program.command('deploy').action(function() {
  return new Deployer().deploy();
});

program.parse(process.argv);

if (!program.args.length) {
  return program.help();
}
