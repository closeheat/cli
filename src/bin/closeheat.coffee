program = require('commander')

program.version('0.0.1').usage('<keywords>').parse(process.argv)
return program.help() unless program.args.length

console.log 'Keywords: ' + program.args
