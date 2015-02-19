var Log, bar, fs, images, path, pictureTube, _;

pictureTube = require('picture-tube');

path = require('path');

fs = require('fs');

bar = require('terminal-bar');

images = require('ascii-images');

_ = require('lodash');

module.exports = Log = (function() {
  function Log() {}

  Log.logo = function() {
    var logo_path, tube;
    tube = pictureTube({
      cols: 5
    });
    tube.pipe(process.stdout);
    logo_path = path.resolve(__dirname, './img/full.png');
    fs.createReadStream(logo_path).pipe(tube);
    return this.center('[ closeheat ]');
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

  return Log;

})();
