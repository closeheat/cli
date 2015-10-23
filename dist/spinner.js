var Log, Spinner;

Log = require('./log');

module.exports = Spinner = (function() {
  var chalk, index, sequence, start, stop, timer, util;
  util = require('util');
  chalk = require('chalk');
  sequence = [chalk.blue('-'), chalk.red('\\'), chalk.yellow('|'), chalk.green('/')];
  index = 0;
  timer = void 0;
  start = function(msg) {
    var single_spin_ms;
    if (msg == null) {
      msg = '';
    }
    single_spin_ms = 150;
    index = 0;
    process.stdout.write(sequence[index] + " " + msg);
    return timer = setInterval((function() {
      process.stdout.write(sequence[index].replace(/./g, "\r"));
      index = index < sequence.length - 1 ? index + 1 : 0;
      return process.stdout.write(sequence[index]);
    }), single_spin_ms);
  };
  stop = function() {
    clearInterval(timer);
    process.stdout.write(sequence[index].replace(/./g, "\r"));
    return console.log(chalk.blue('-'));
  };
  return {
    start: start,
    stop: stop
  };
})();
