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

SlugManager = require './slug_manager'
GitHubManager = require './github_manager'
Website = require './website'

shepherd = require("shepherd")

module.exports =
class ContinuousDeployment
  constructor: ->
    @git = new Git()

  start: ->
    Log.p('You are about to publish a new website.')
    @run()

  promisify: (result) ->
    new Promise (resolve, reject) ->
      resolve(result)

  useOrGet: (opts, thing, get) ->
    if opts[thing]
      @promisify(opts[thing])
    else
      console.log 'gettin'
      console.log get
      get

  run: (opts = {}) ->
    # console.log opts
    # deps = {
    #   slug: @useOrGet(opts, 'slug', -> SlugManager.choose(opts))
    #   repo: @useOrGet(opts, 'repo', -> GitHubManager.choose(opts) )
    #   website: @useOrGet(opts, 'website', -> Website.create(opts) )
    # }
    #
    # sequence = ['slug', 'repo', 'website']
    # filled = _.pick deps, _.isString
    # missing = _.without(sequence, filled...)
    # console.log missing
    #
    seq = [
      { key: 'slug', fn: SlugManager.choose }
      { key: 'repo', fn: GitHubManager.choose }
      { key: 'website', fn: Website.create }
    ]

    only = _.reject seq, (obj) -> _.include(_.keys(opts), obj.key)
    return opts if _.isEmpty(only)
    console.log _.keys(opts)

    runner = Promise.reduce only, (opts, obj) ->
      obj.fn(opts).then (result) ->
        console.log 'last'
        console.log result
        result
    , {}

    runner.then (opts) =>
      @run(opts)
      # st(missing)]().then (new_opts) =>
      # @run(new_opts)


    # graph = new shepherd.Graph()
    # graph.add 'slug', SlugManager.choose, ['validated_slug']
    # graph.add 'repo', GitHubManager.choose, ['validated_slug']
    # graph.add 'website', Website.create, ['slug', 'repo', 'validated_slug']
    #
    # builder = graph.newBuilder().builds('website')
    # builder.run(opts)

  exec: (opts) ->
    @run(opts)
      .then (data) ->
        console.log(data)
        console.log 'ehe'
        console.log(arguments)
      .fail (err) =>
        console.log 'FAIL'
        @exec(validated_slug: 'hello', repo: 'hello').then ->
          console.log 'OTHER'
        # another = graph.newBuilder().builds('website').using({'slug': { _literal: 'This is my string' }})
        # console.log 'OTHER'
        # console.log graph.deleter('slug')
        # graph.deleter('slug').then ->
        #   console.log 'emeil'
        #
        #   builder.run().then (ea) ->
        #     console.log arguments
        #   console.log 'AFEERFAIL'
        # builder.add



  ensureNoWebsite: (data) ->
    GitRepository.exists().then (repo) =>
      return unless repo.exists

      Website.exists(repo.name).then (website) =>
        return unless website.exists

        @exec(ensure_no_website: website_exists)


  configure: ->
    @ensureWebsiteDoesntExist().then ->
      SlugManager.choose().then (slug) ->
        GitHubManager.choose(slug).then (repo) ->
          AppManager.create(slug, repo)

  ensureWebsiteDoesntExist: ->
    GitRepository.exists().then (repo) =>
      return unless repo.exists

      Website.exists(repo.name).then (website) =>
        return unless website.exists

        @exists(website.slug, website.repo) if website.exists

  exists: (result) ->
    Log.p "Hey there! This folder is already published to closeheat."
    Log.p "It is available at #{Color.violet("#{result.slug}.closeheatapp.com")}."
    Log.p "You can open it swiftly by typing #{Color.violet('closeheat open')}."
    Log.br()
    Log.p "It has a continuous deployment setup from GitHub at #{result.repo}"
    Log.br()
    Log.p "Anyways - if you'd like to publish your current code changes, just type:"
    Log.p Color.violet('closeheat quick-publish')
    Log.p "Doing that will commit and push all of your changes to the GitHub repository and publish it."
    process.exit()

  success: (opts) ->
    slug = opts.slug
    repo = opts.repo

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
