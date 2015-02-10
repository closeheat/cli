var Paths, homePath, path;

path = require('path');

homePath = require('home-path');

module.exports = Paths = (function() {
  function Paths(app_name) {
    var tmp_token;
    this.target = path.join(process.cwd(), app_name);
    tmp_token = '353cleaned5sometime';
    this.tmp = "" + (homePath()) + "/.closeheat/tmp/creations/" + tmp_token + "/";
    this.parts = path.join(this.tmp, 'parts');
    this.whole = path.join(this.tmp, 'whole');
    this.transformed = path.join(this.tmp, 'transformed');
  }

  return Paths;

})();
