var JadePreprocessor, gutil, html2jade, through;

html2jade = require('html2jade');

through = require('through2');

gutil = require('gulp-util');

module.exports = JadePreprocessor = (function() {
  function JadePreprocessor() {}

  JadePreprocessor.prototype.exec = function(options) {
    return through.obj(function(file, enc, cb) {
      var html;
      if (file.isNull()) {
        cb(null, file);
        return;
      }
      options = options || {};
      html = file.contents.toString();
      return html2jade.convertHtml(html, options, function(err, jade) {
        file.contents = new Buffer(jade);
        file.path = gutil.replaceExtension(file.path, ".jade");
        return cb(null, file);
      });
    });
  };

  return JadePreprocessor;

})();
