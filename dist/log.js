var Couleurs, Log, Spinner, bar, c256, chalk, colors, fs, images, path, pictureTube, _;

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

  Log.spin = function(msg, fn) {
    return Spinner.start(msg);
  };

  Log.spinStop = function() {
    return Spinner.stop();
  };

  return Log;

})();
