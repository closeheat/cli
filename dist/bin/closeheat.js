#!/usr/bin/env node

var Creator, Server, program, _;

program = require('commander');

_ = require('lodash');

Creator = require('../creator');

Server = require('../server');

program.version('0.0.1').usage('<keywords>');

program.command('create [name]').alias('new').description('creates a new app with clean setup and directory structure').option('-f, --framework [name]', 'Framework').option('-t, --template [name]', 'Template').option('--javascript [name]', 'Javascript precompiler').option('--html [name]', 'HTML precompiler').option('--css [name]', 'CSS precompiler').action(function(name, opts) {
  var settings;
  settings = _.pick(opts, 'framework', 'template', 'javascript', 'html', 'css');
  if (_.isEmpty(settings)) {
    return new Creator().createFromPrompt(name);
  } else {
    return new Creator().createFromSettings(name, settings);
  }
});

program.command('server').action(function() {
  return new Server().start();
});

program.parse(process.argv);

if (!program.args.length) {
  return program.help();
}
