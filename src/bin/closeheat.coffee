program = require 'commander'
Creator = require '../creator'

program
  .version('0.0.1')
  .usage('<keywords>')

program
  .command('create [name]')
  .alias('new')
  .description('creates a new app with clean setup and directory structure')
  .action (name) ->
    console.log 'name was ' + name
    new Creator().create()

program.parse(process.argv)

return program.help() unless program.args.length
