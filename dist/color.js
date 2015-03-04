var Color, Couleurs, chalk;

Couleurs = require('couleurs')();

chalk = require('chalk');

module.exports = Color = (function() {
  var ORANGE, RED, RED_YELLOW, VIOLET;

  function Color() {}

  ORANGE = '#FFBB5D';

  VIOLET = '#3590F3';

  RED = '#F8006C';

  RED_YELLOW = '#FF6664';

  Color.orange = function(msg) {
    return Couleurs.fg(msg, ORANGE);
  };

  Color.red = function(msg) {
    return Couleurs.fg(msg, RED);
  };

  Color.redYellow = function(msg) {
    return Couleurs.fg(msg, RED_YELLOW);
  };

  Color.violet = function(msg) {
    return Couleurs.fg(msg, VIOLET);
  };

  Color.bare = function(msg) {
    return chalk.stripColor(msg);
  };

  return Color;

})();
