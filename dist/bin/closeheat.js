#!/usr/bin/env node

var program;

program = require('commander');

program.version('0.0.1').usage('<keywords>').parse(process.argv);

if (!program.args.length) {
  return program.help();
}

console.log('Keywords: ' + program.args);
