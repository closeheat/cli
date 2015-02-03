#!/usr/bin/env node

var Creator, program;

program = require('commander');

Creator = require('../creator');

program.version('0.0.1').usage('<keywords>');

program.command('create [name]').alias('new').description('creates a new app with clean setup and directory structure').action(function(name) {
  return new Creator().create(name);
});

program.parse(process.argv);

if (!program.args.length) {
  return program.help();
}
