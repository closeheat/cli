expect = require('chai').expect

command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'
TestConfig = require './helpers/test_config'
TestGit = require './helpers/test_git'
Config = require '../src/config'

success = (repo) ->
  """
  Setting up your website...
  Success!
  Your website example-subdomain.closeheatapp.com is now published.
  Every change to master branch on #{repo} in GitHub will be immediately published.
  The logs of each change are available with closeheat log.
  It\'s useful to have them right after your push your changes like: git push origin master && closeheat log
  """

describe 'publish', ->
  beforeEach (done) ->
    @api = new TestApi()
    @server = @api.start()
    TestGit.init().then(-> done())

    @api.routes.post '/suggest/slug', (req, res) ->
      res.send
        slug: 'suggested-slug'

  afterEach ->
    @server.close()

  # TODO: test when
  # ? maybe - .git doesnt exist
  # - git not installed

  describe 'GitHub repository exits', ->
    beforeEach (done) ->
      TestGit.addRemote().then(-> done())

    it 'continuous deployment already configured', (done) ->
      @timeout(5000)

      @api.routes.post '/apps/find', (req, res) ->
        res.send
          app:
            exists: true
            slug: 'existing-slug'
            github_repo: 'example-org/example-repo'

      command('publish').then (stdout) ->
        assertStdout stdout,
          """
          Hey there! This folder is already published to closeheat.
          It is available at existing-slug.closeheatapp.com.
          You can open it swiftly by typing closeheat open.
          It has a continuous deployment setup from GitHub at example-org/example-repo
          Anyways - if you'd like to publish your current code changes, just type:
          closeheat quick-publish
          Doing that will commit and push all of your changes to the GitHub repository and publish it.
          """
        done()

    it 'not configured - use existing repo', (done) ->
      @api.routes.post '/apps/find', (req, res) ->
        res.send
          app:
            exists: false

      @timeout(5000)

      @api.routes.post '/publish', (req, res) ->
        res.send
          app:
            url: 'http://example-subdomain.closeheatapp.com'
            github_repo_url: 'git@github.com:example-org/example-repo.git'
          pusher:
            key: ''
            auth_endpoint: 'http://example.com/pusher/auth'
            user_key: 'private-user-15'

      prompts = [
        {
          question: 'Choose a subdomain'
          answer: 'example-subdomain'
        }
      ]

      command('publish', prompts: prompts).then (stdout) ->
        assertStdout stdout,
          """
          You are about to publish a new website.
          ? Choose a subdomain - XXX.closeheatapp.com: (suggested-slug)
          ? Choose a subdomain - XXX.closeheatapp.com: example-subdomain
          Using your existing GitHub repository: example-org/example-repo
          #{success('example-org/example-repo')}
          """
        done()

    # NIXT cant respond to multiple inputs with same question
    # it 'slug taken', (done) ->
    #   @timeout(5000)
    #
    #   @api.routes.post '/apps/find', (req, res) ->
    #     res.send
    #       app:
    #         exists: false
    #
    #   time = 1
    #   @api.routes.post '/publish', (req, res) ->
    #     console.log 'got'
    #     if time == 1
    #       console.log 'got2'
    #       res.status(405).send
    #         type: 'slug-exists'
    #         message: 'The subdomain is already taken.'
    #     else
    #       console.log 'got3'
    #       res.send
    #         success: true
    #         url: 'http://example-subdomain.closeheatapp.com'
    #         github_repo_url: 'git@github.com:example-org/example-new-repo.git'
    #
    #     time = 2
    #
    #   prompts = [
    #     {
    #       question: 'What subdomain would you like'
    #       answer: 'example-subdomain'
    #     }
    #     {
    #       question: 'What subdomain would you like'
    #       answer: 'example-subdomain'
    #     }
    #   ]
    #
    #   command('publish', prompts: prompts).then (stdout) ->
    #     assertStdout stdout,
    #       """
    #       You are about to publish a new website.
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] (suggested-slug)
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] example-subdomain
    #       Using your existing GitHub repository: example-org/example-repo
    #       Subdomain example-subdomain is already taken. Could you choose another one?
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] (suggested-slug)
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] example-subdomain
    #       #{success('example-org/example-repo')}
    #       """
    #     done()
  describe 'GitHub repository does not exist', ->
    beforeEach ->
      @api.routes.get '/users/me', (req, res) ->
        res.send
          user:
            github_username: 'example-user'

    it 'show instructions', (done) ->
      @timeout(5000)

      # @api.routes.post '/publish', (req, res) ->
      #   res.send
      #     app:
      #       url: 'http://example-subdomain.closeheatapp.com'
      #       github_repo_url: 'git@github.com:example-org/example-new-repo.git'

      prompts = [
        {
          question: 'Choose a subdomain'
          answer: 'example-subdomain'
        }
        # {
        #   question: 'Choose a GitHub repository'
        #   answer: 'example-org/example-new-repo'
        # }
      ]

      command('publish', prompts: prompts).then (stdout) ->
        assertStdout stdout,
          """
          You are about to publish a new website.
          ? Choose a subdomain - XXX.closeheatapp.com: (suggested-slug)
          ? Choose a subdomain - XXX.closeheatapp.com: example-subdomain
          This folder is not in a GitHub repository.
          Set up GitHub repository first: https://github.com/new
          """
        done()
