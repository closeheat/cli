inquirer = require 'inquirer'
path = require 'path'
Promise = require 'bluebird'
inquirer = require 'inquirer'

Urls = require './urls'
SlugManager = require './slug_manager'
Log = require './log'
Authorized = require './authorized'
Color = require './color'

module.exports =
class AppManager
  @create: (slug, repo) =>
    @execRequest(slug, repo)

  @execRequest: (slug, repo) ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.publishNewWebsite(), qs: { repo: repo, slug: slug }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        if resp.body.success
          resolve(opts)
        else
          reject(slug: slug, repo: repo, error: 'app-exists')
