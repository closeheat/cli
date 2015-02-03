
module.exports =
class Creator
  create: ->
    url = 'https://api.github.com/search/repositories?sort=stars&order=desc&q=closeheat'

    request = require 'request'

    request {
      method: 'GET'
      headers: 'User-Agent': 'closeheat'
      url: url
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        body = JSON.parse(body)

        i = 0
        while i < body.items.length
          chalk = require 'chalk'
          console.log chalk.cyan.bold.underline('Name: ' + body.items[i].name)
          console.log chalk.magenta.bold('Owner: ' + body.items[i].owner.login)
          i++
      else if error
        chalk = require 'chalk'
        console.log chalk.red('Error: ' + error)
