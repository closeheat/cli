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

module.exports =
class Publisher
  constructor: ->
    @git = new Git()

  publish: ->
    @isGitRepo().then (is_git_repo) ->
      console.log is_git_repo
      if (is_git_repo)
        @isCloseheatApp().then (is_closeheat_app) ->
          if (is_closeheat_app)
            # ask for commit msg
          else
            # ask for new closeheat app name
      else
        @newWebsite()
        # ask for new closeheat app name

  newWebsite: ->
    Log.p('You are about to publish a new website.')

    # will automatically check if cli is authenticated
    authorizer = new Authorizer()

    authorizer.ensureGitHubAuthorized().then =>
      @checkContinousDeliveryExists().then (result) =>
        if (result.exists)
          Log.p "Hey there! This folder is already published to closeheat."
          Log.p "It is available at #{Color.violet("#{result.slug}.closeheatapp.com")}."
          Log.p "You can open it swiftly by typing #{Color.violet('closeheat open')}."
          Log.br()
          Log.p "It has a continuous deployment setup from GitHub at #{result.repo_url}"
          Log.br()
          Log.p "Anyways - if you'd like to publish your current code changes, just type:"
          Log.p Color.violet('closeheat quick-publish')
          Log.p "Doing that will commit and push all of your changes to the GitHub repository and publish it."
        else
          @setupContinousDelivery()

  checkContinousDeliveryExists: ->
    new Promise (resolve, reject) =>
      return resolve(exists: false) unless fs.existsSync('.git')

      @getGitHubRepoUrl().then (repo) ->
        return resolve(exists: false) unless repo

        Authorized.request url: Urls.deployedSlug(), qs: { repo: repo }, method: 'post', json: true, (err, resp) ->
          return reject(err) if err
          return resolve(exists: false) if _.isUndefined(resp.body.slug)

          resolve(exists: true, slug: resp.body.slug, repo_url: repo_url)

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  getGitHubRepoUrl: ->
    new Promise (resolve, reject) =>
      @git.exec 'remote', ['--verbose'], (err, resp) ->
        return reject(err) if err

        # TODO: select only GitHub repo
        resolve(resp.match(GITHUB_REPO_REGEX)[1])

  setupContinousDelivery: ->
    @askSlug().then (slug) =>
      @getGitHubRepoUrl().then (repo_url) =>
        if repo_url
          @askReuseGitHubRepo(repo_url).then (reuse) =>
            if reuse
              @attachGitHubHooks(repo_url, slug).then =>
                @successfulSetup(repo_url, slug)
            else
              @createNewGitHubRepo(slug)
        else
          @createNewGitHubRepo(slug)

  createNewGitHubRepo: (slug) ->
    @askNewRepoName().then (repo) ->
      @publishWithGitHubRepo(repo, slug).then ->
        @successfulSetup(repo, slug)

  successfulSetup: (repo, slug) ->
    Log.p 'Success!'
    Log.p "Your website #{Color.violet("#{slug}.closeheatapp.com")} is now published."
    Log.br()
    Log.p "GitHub repository #{repo} is setup for continuous deployment."
    Log.p "Every change to master branch will be immediately published."
    Log.br()
    Log.p "The logs of each deploy are available with #{Color.violet('closeheat log')}."
    Log.p "It's useful to have them right after your #{Color.violet('git push')} with #{Color.violet('git push origin master && closeheat log')}"
    Log.br()
    Log.p "To set up a custom domain or change a public directory type:"
    # Just opens http://app.closeheat.com/apps/app-name/settings
    Log.code 'closeheat settings'

  askSlug: ->
    @suggestDefaultSlug().then (slug) =>
      new Promise (resolve, reject) =>
        inquirer.prompt {
          message: 'What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later)'
          name: 'slug'
          default: slug
        }, (answer) =>

          @isFreeSlug(answer.slug).then (is_free) =>
            if is_free
              resolve(answer.slug)
            else
              Log.p 'This slug is used'
              @askSlug()

  askNewRepoName: ->
    @suggestDefaultRepo().then (repo) =>
      new Promise (resolve, reject) =>
        inquirer.prompt {
          message: 'What is the GitHub repository would you like to create for this website? Ex. Nedomas/NAME?'
          name: 'repo'
          default: repo
        }, (answer) =>
          @isFreeRepo(answer.repo).then (is_free) =>
            if is_free
              resolve(answer.repo)
            else
              Log.p 'You already have a GitHub repo with this name.'
              @askSlug()

  isFreeSlug: (slug) ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.isFreeSlug(), qs: { slug: slug }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve(resp.body.free)

  isFreeRepo: (repo) ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.isFreeRepo(), qs: { repo: repo }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve(resp.body.free)

  folder: ->
    _.last(process.cwd().split('/'))

  suggestDefaultRepo: ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.suggestGitHubRepo(), qs: { folder: @folder() }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve(resp.name)

  suggestDefaultSlug: ->
    new Promise (resolve, reject) =>
      Authorized.request url: Urls.suggestSlug(), qs: { folder: @folder() }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve(resp.body.slug)

  attachGitHubHooks: (repo_url, slug) ->
    new Promise (resolve, reject) ->
      Authorized.request url: Urls.setupExistingRepo(), qs: { repo: repo_url, slug: slug }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        resolve()

  askReuseGitHubRepo: (repo_name) ->
    new Promise (resolve, reject) =>
      inquirer.prompt({
        message: "Would you like to use your existing #{repo_name} GitHub repository repo for continuos delivery?"
        type: 'confirm'
        name: 'reuse'
      }, (answer) ->
        resolve(answer.reuse)
      )

  quickPublish: ->
    Log.spin('Deploying the app to closeheat.com via GitHub.')
    @initGit().then(=>
      @addEverything().then =>
        Log.stop()
        Log.inner('All files added.')
        @commit('Quick deploy').then =>
          Log.inner('Files commited.')
          Log.inner('Pushing to GitHub.')
          @pushToMainBranch().then (branch) ->
            Log.inner("Pushed to #{branch} branch on GitHub.")
            new DeployLog().fromCurrentCommit().then (deployed_name) ->
              Notifier.notify('app_deploy', deployed_name)
              url = "http://#{deployed_name}.closeheatapp.com"
              Log.p("Website published at #{Color.violet(url)}.")
              Log.p('Open it with:')
              Log.code('closeheat open')
    ).catch((err) ->
      Log.error(err)
    ).finally ->
      # process.exit(0)

  initGit: ->
    new Promise (resolve, reject) =>
      return resolve() if fs.existsSync('.git')

      @git.exec 'init', (err, resp) ->
        resolve()

  addEverything: ->
    new Promise (resolve, reject) =>
      @git.exec 'add', ['.'], (err, resp) ->
        return reject(err) if err

        resolve()

  commit: (msg) ->
    new Promise (resolve, reject) =>
      @git.exec 'commit', m: true, ["'#{msg}'"], (err, resp) ->
        resolve()

  pushToMainBranch: ->
    new Promise (resolve, reject) =>
      @ensureAppAndRepoExist().then =>
        @getMainBranch().then (main_branch) =>
          @push(main_branch).then ->
            resolve(main_branch)

  ensureAppAndRepoExist: ->
    new Promise (resolve, reject) =>
      @repoExist().then (exist) =>
        if exist
          resolve()
        else
          @askToCreateApp().then(resolve)

  askToCreateApp: ->
    new Promise (resolve, reject) =>
      inquirer.prompt({
        message: 'This app is not deployed yet. Would you like create a new closeheat app and deploy via GitHub?'
        type: 'confirm'
        name: 'create'
      }, (answer) ->
        if answer.create
          new Initializer().init().then(resolve)
        else
          Log.error 'You cannot deploy this app without the closeheat backend and GitHub setup'
      )

  repoExist: ->
    new Promise (resolve, reject) =>
      @git.exec 'remote', (err, msg) ->
        return reject(err) if err

        origin = msg.match(/origin/)
        resolve(origin)

  getMainBranch: ->
    new Promise (resolve, reject) =>
      @git.exec 'symbolic-ref', ['--short', 'HEAD'], (err, msg) ->
        return reject(err) if err

        resolve(msg.trim())

  push: (branch) ->
    new Promise (resolve, reject) =>
      @git.exec 'push', ['origin', branch], (err, msg) ->
        return reject(err) if err

        resolve()

  GITHUB_REPO_REGEX = /origin*.+:(.+\/.+).git \(push\)/
  getOriginRepo: ->
    new Promise (resolve, reject) =>
      @git.exec 'remote', ['--verbose'], (err, resp) ->
        return reject(err) if err

        resolve(resp.match(GITHUB_REPO_REGEX)[1])

  open: ->
    @getOriginRepo().then (repo) =>
      @getSlug(repo).then (slug) ->
        url = "http://#{slug}.closeheatapp.com"
        Log.p "Opening your app at #{url}."
        open(url) unless process.env.CLOSEHEAT_TEST

  getSlug: (repo) ->
    new Promise (resolve, reject) ->
      Authorized.request url: Urls.deployedSlug(), qs: { repo: repo }, method: 'post', json: true, (err, resp) ->
        return reject(err) if err

        if _.isUndefined(resp.body.slug)
          msg = "Could not find your closeheat app with GitHub repo '#{repo}'. Please deploy the app via UI"
          return Log.error(msg)

        resolve(resp.body.slug)
