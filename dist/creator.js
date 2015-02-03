var Creator;

module.exports = Creator = (function() {
  function Creator() {}

  Creator.prototype.create = function() {
    var request, url;
    url = 'https://api.github.com/search/repositories?sort=stars&order=desc&q=closeheat';
    request = require('request');
    return request({
      method: 'GET',
      headers: {
        'User-Agent': 'closeheat'
      },
      url: url
    }, function(error, response, body) {
      var chalk, i, _results;
      if (!error && response.statusCode === 200) {
        body = JSON.parse(body);
        i = 0;
        _results = [];
        while (i < body.items.length) {
          chalk = require('chalk');
          console.log(chalk.cyan.bold.underline('Name: ' + body.items[i].name));
          console.log(chalk.magenta.bold('Owner: ' + body.items[i].owner.login));
          _results.push(i++);
        }
        return _results;
      } else if (error) {
        chalk = require('chalk');
        return console.log(chalk.red('Error: ' + error));
      }
    });
  };

  return Creator;

})();
