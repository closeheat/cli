var Spinner;

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
    util.print("" + sequence[index] + " " + msg);
    return timer = setInterval((function() {
      util.print(sequence[index].replace(/./g, "\r"));
      index = index < sequence.length - 1 ? index + 1 : 0;
      return util.print(sequence[index]);
    }), single_spin_ms);
  };
  stop = function() {
    clearInterval(timer);
    util.print(sequence[index].replace(/./g, "\r"));
    return util.puts(chalk.blue('-'));
  };
  return {
    start: start,
    stop: stop
  };
})();
