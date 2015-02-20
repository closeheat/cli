var Color, Couleurs, Log, Spinner, bar, c256, chalk, colors, fs, images, path, pictureTube, _;

pictureTube = require('picture-tube');

path = require('path');

fs = require('fs');

bar = require('terminal-bar');

images = require('ascii-images');

_ = require('lodash');

chalk = require('chalk');

colors = require('ansi-256-colors');

c256 = require("colors-256")();

Couleurs = require("couleurs")();

Spinner = require('./spinner');

Color = require('./color');

module.exports = Log = (function() {
  function Log() {}

  Log.logo = function(br) {
    var block_colours, blocks;
    if (br == null) {
      br = 1;
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

  Log.error = function(msg) {
    return this.line("" + (Color.red('ERROR')) + " | " + msg);
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
    return this.p("" + (chalk.blue('-')) + " " + msg);
  };

  Log.backend = function(msg) {
    return Log.inner("" + (Color.orange('closeheat')) + " | " + msg);
  };

  return Log;

})();
