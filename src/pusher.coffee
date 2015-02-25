_ = require 'lodash'
Promise = require 'bluebird'
shell = require 'shelljs'
Git = require 'git-wrapper'

Urls = require './urls'
Deployer = require './deployer'

Log = require './log'
Color = require './color'

Authorized = require './authorized'

module.exports =
class Pusher
  constructor: (@name, @target) ->
    @git = new Git()

    # check if closeheat is github authorized
    # - if not, force auth via link http://closeheat.com/authorize-github
    # create an app with repo, hooks
    # add, commit files and push to repo as master (do auto deploy)

  push: ->
    @getGithubUsername().then((username) =>
      Log.inner("Using Github username: #{Color.orange(username)}")
      Log.spin('Creating closeheat app and Github repository.')
      @createAppInBackend().then (resp) =>
        Log.stop()
        Log.inner("Created both with name '#{@name}'.")

        @pushFiles(username).then =>
          Log.br()
          Log.p "The app #{Color.violet(@name)} has been created."
          Log.br()

    ).catch (err) ->
      Log.error(err)

  githubNotAuthorized: ->
    Log.error('Github not authorized', false)
    Log.innerError "We cannot set you up for deployment because you did not authorize Github."
    Log.br()
    Log.innerError "Visit #{Urls.authorizeGithub()} and rerun the command."

  createAppInBackend: =>
    new Promise (resolve, reject) =>
      Authorized.request { url: Urls.createApp(), qs: { repo_name: @name }, method: 'post' }, (err, resp) =>
        return reject(err) if err

        resolve(resp)

  getGithubUsername: ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.currentUserInfo(), method: 'get', (err, resp) =>
        return reject(err) if err

        try
          user_info = JSON.parse(resp.body).user
        catch e
          return Log.error('Backend responded with an error.')

        if user_info['github_token']
          resolve(user_info['github_username'])
        else
          @githubNotAuthorized()

  pushFiles: (username) =>
    shell.cd(@target)

    @initGit().then =>
      @addRemote(username).then ->

      new Deployer().deploy().then ->
        shell.cd('..')

  addRemote: (username) =>
    new Promise (resolve, reject) =>
      git_url = "git@github.com:#{username}/#{@name}.git"

      @git.exec 'remote', ['add', 'origin', git_url], (err, resp) ->
        return reject(err) if err

        resolve()

  initGit: =>
    new Promise (resolve, reject) =>
      @git.exec 'init', [@target], (err, resp) ->
        return reject(err) if err

        resolve()
