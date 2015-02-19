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

  Log.logo = function() {
    var block_colours, blocks;
    block_colours = ['#FFBB5D', '#FF6664', '#F8006C', '#3590F3'];
    blocks = _.map(block_colours, function(hex) {
      return Couleurs.bg(' ', hex);
    });
    this.line(blocks.join('') + blocks.reverse().join(''));
    return this.line();
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
    return Spinner.start(msg);
  };

  Log.stop = function() {
    return Spinner.stop();
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

  return Log;

})();
