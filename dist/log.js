var Authorizer, Color, Config, Couleurs, Log, Promise, Spinner, _, chalk, opbeat;

_ = require('lodash');

chalk = require('chalk');

Couleurs = require('couleurs')();

Promise = require('bluebird');

opbeat = require('opbeat')({
  clientLogLevel: 'fatal',
  active: 'true',
  logger: {
    fatal: function() {},
    debug: function() {},
    info: function() {}
  }
});

Spinner = require('./spinner');

Color = require('./color');

Authorizer = require('./authorizer');

Config = require('./config');

module.exports = Log = (function() {
  function Log() {}

  Log.logo = function(br) {
    var block_colours, blocks;
    if (br == null) {
      br = 1;
    }
    if (!global.COLORS) {
      return '';
    }
    block_colours = ['#FFBB5D', '#FF6664', '#F8006C', '#3590F3'];
    blocks = _.map(block_colours, function(hex) {
      return Couleurs.bg(' ', hex);
    });
    this.line(blocks.join('') + blocks.reverse().join(''));
    return this.br(br);
  };

  Log.center = function(text) {
    var start, total;
    total = _.min([process.stdout.columns, 80]);
    start = total / 2 - text.length;
    this.line();
    return this.line("" + (_.repeat(' ', start)) + text);
  };

  Log.line = function(text) {
    if (text == null) {
      text = '';
    }
    return console.log(text);
  };

  Log.p = function(text) {
    if (text == null) {
      text = '';
    }
    return console.log(text);
  };

  Log.br = function(times) {
    if (times == null) {
      times = 1;
    }
    return _.times(times, (function(_this) {
      return function() {
        return _this.line();
      };
    })(this));
  };

  Log.inner = function(msg) {
    return this.line("  " + msg);
  };

  Log.innerError = function(msg, exit) {
    if (exit == null) {
      exit = true;
    }
    this.line("        " + msg);
    if (exit) {
      return process.exit();
    }
  };

  Log.spin = function(msg, fn) {
    if (this.spinning === true) {
      Spinner.stop();
    }
    Spinner.start(msg);
    return this.spinning = true;
  };

  Log.stop = function() {
    if (this.spinning === true) {
      Spinner.stop();
      return this.spinning = false;
    }
  };

  Log.error = function(msg, exit, err, type) {
    if (exit == null) {
      exit = true;
    }
    if (err == null) {
      err = '';
    }
    this.stop();
    this.br();
    this.line((Color.red('ERROR')) + " | " + msg);
    this.br();
    return this.sendErrorLog(msg).then(function() {
      if (exit) {
        return process.exit();
      }
    });
  };

  Log.sendErrorLog = function(msg) {
    return new Promise(function(resolve, reject) {
      var StackTrace;
      opbeat.on('logged', resolve);
      opbeat.on('error', resolve);
      StackTrace = require('stacktrace-js');
      return StackTrace.get().then(function(trace) {
        return opbeat.captureError(msg, {
          extra: {
            closeheat_version: Config.version(),
            token: new Authorizer().accessToken(),
            trace: trace
          }
        });
      });
    });
  };

  Log.backendError = function() {
    return this.error('Backend responded with an error.');
  };

  Log.code = function(msg) {
    this.br();
    if (_.isArray(msg)) {
      return _.each(msg, (function(_this) {
        return function(m) {
          return _this.inner(Color.violet(m));
        };
      })(this));
    } else {
      return this.inner(Color.violet(msg));
    }
  };

  Log.secondaryCode = function(msg) {
    this.br();
    if (_.isArray(msg)) {
      return _.each(msg, (function(_this) {
        return function(m) {
          return _this.inner(m);
        };
      })(this));
    } else {
      return this.inner(msg);
    }
  };

  Log.doneLine = function(msg) {
    return this.p((chalk.blue('-')) + " " + msg);
  };

  Log.backend = function(data) {
    if (data.type === 'error') {
      return Log.inner((Color.orange('closeheat')) + " | " + (Color.red(data.message)));
    } else {
      return Log.inner((Color.orange('closeheat')) + " | " + data.message);
    }
  };

  return Log;

})();
