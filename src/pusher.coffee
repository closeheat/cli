request = require 'request'
_ = require 'lodash'
q = require 'bluebird'
git = require 'gulp-git'
fs = require('fs-extra')
shell = require('shelljs')

Authorizer = require './authorizer'
Urls = require './urls'
Deployer = require './deployer'

module.exports =
class Pusher
  constructor: (@name, @target) ->
    authorizer = new Authorizer

    @token_params =
      api_token: authorizer.accessToken()

    # check if closeheat is github authorized
    # - if not, force auth via link http://closeheat.com/authorize-github
    # create an app with repo, hooks
    # add, commit files and push to repo as master (do auto deploy)

  push: ->
    console.log 'pushin'
    @getGithubUsername().then (username) =>
      console.log 'auth'
      @createAppInBackend().then (resp) =>
        console.log 'created'
        @pushFiles(username).then =>
          console.log 'files pushed'

  handleCreationError: (error) =>
    console.log(error)

  githubNotAuthorized: =>
    console.log "We cannot set you up for deployment because you did not authorize Github."
    console.log ""
    console.log "Visit #{Urls.authorizeGithub()} and rerun the command."

  createAppInBackend: =>
    new q (resolve, reject) =>
      request { url: Urls.createApp(), qs: _.merge(repo_name: @name, @token_params), method: 'post' }, (err, resp) =>
        console.log 'created'
        return @handleCreationError(error) if err

        resolve(resp)

  getGithubUsername: ->
    new q (resolve, reject) =>
      request url: Urls.currentUserInfo(), qs: @token_params, method: 'get', (err, resp) =>
        throw Error 'Error happened' if err

        user_info = JSON.parse(resp.body).user

        if user_info['github_token']
          resolve(user_info['github_username'])
        else
          @githubNotAuthorized()

  pushFiles: (username) =>
    @initGit().then =>
      console.log 'inited'
      @addRemote(username)
      console.log 'remote added'

      shell.cd(@target)
      new Deployer().deploy("#{@target}/**").then ->
        shell.cd('..')

  addRemote: (username) =>
    content = "[remote \"origin\"]\n        url = git@github.com:#{username}/#{@name}.git\n        fetch = +refs/heads/*:refs/remotes/origin/*"
    fs.appendFileSync("#{@target}/.git/config", content)

  initGit: =>
    new q (resolve, reject) =>
      git.init args: "#{@target} --quiet", (err) ->
        throw err if (err)

        resolve()
