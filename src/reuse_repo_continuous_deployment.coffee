Promise = require 'bluebird'
inquirer = require 'inquirer'
_ = require 'lodash'
open = require 'open'
fs = require 'fs.extra'

Git = require './git'
Initializer = require './initializer'
Authorized = require './authorized'
Authorizer = require './authorizer'
Urls = require './urls'
DeployLog = require './deploy_log'

Log = require './log'
Color = require './color'
Notifier = require './notifier'
UserInput = require './user_input'

module.exports =
class ReuseRepoContinuousDeployment
  @start: (existing_repo, slug) ->
    new Promise (resolve, reject) =>
      UserInput.reuseRepo(existing_repo).then (reuse) =>
        return reject(slug: slug) unless reuse

        resolve(existing_repo)
