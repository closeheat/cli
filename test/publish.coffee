expect = require('chai').expect

command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'
TestConfig = require './helpers/test_config'
Config = require '../src/config'

success = (repo) ->
  """
  Success!
  Your website example-subdomain.closeheatapp.com is now published.
  GitHub repository #{repo} is setup for continuous deployment.
  Every change to master branch will be immediately published.
  The logs of each deploy are available with closeheat log.
  It\'s useful to have them right after your git push with git push origin master && closeheat log
  To set up a custom domain or change a public directory type:
    closeheat settings
  """

describe 'publish', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  # TODO: test when
  # ? maybe - .git doesnt exist
  # - git not installed

  it 'continuous deployment already configured', (done) ->
    @timeout(5000)

    @api.routes.post '/apps/from_repo', (req, res) ->
      res.send
        exists: true
        slug: 'existing-slug'

    command('publish').then (stdout) ->
      assertStdout stdout,
        """
        TEST: Executing 'git remote --verbose'
        Hey there! This folder is already published to closeheat.
        It is available at existing-slug.closeheatapp.com.
        You can open it swiftly by typing closeheat open.
        It has a continuous deployment setup from GitHub at example-org/example-repo
        Anyways - if you'd like to publish your current code changes, just type:
        closeheat quick-publish
        Doing that will commit and push all of your changes to the GitHub repository and publish it.
        """
      done()

  describe 'continuous deployment not setup', ->
    beforeEach ->
      @api.routes.post '/apps/from_repo', (req, res) ->
        res.send
          exists: false

      @api.routes.post '/suggest/slug', (req, res) ->
        res.send
          slug: 'suggested-slug'

    it 'use existing repo', (done) ->
      @timeout(5000)

      @api.routes.post '/deploy/new', (req, res) ->
        res.send
          success: true
          url: 'http://example-subdomain.closeheatapp.com'
          repo_url: 'git@github.com:example-org/example-repo.git'

      prompts = [
        {
          question: 'What subdomain would you like'
          answer: 'example-subdomain'
        }
      ]

      opts =
        prompts: prompts
        git: '../test/fixtures/git/dist/default'

      command('publish', opts).then (stdout) ->
        assertStdout stdout,
          """
          TEST: Executing 'git remote --verbose'
          You are about to publish a new website.
          ? What subdomain would you like? [example: HELLO.closeheatapp.com] (suggested-slug)
          ? What subdomain would you like? [example: HELLO.closeheatapp.com] example-subdomain
          ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) (suggested-slug)
          ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) example-subdomain
          TEST: Executing 'git remote --verbose'
          Using your existing GitHub repository: example-org/example-repo
          TEST: Executing 'git remote --verbose'
          #{success('example-org/example-repo')}
          """
        done()

    it 'create new repo', (done) ->
      @timeout(5000)

      @api.routes.get '/users/me', (req, res) ->
        res.send
          name: 'example-user'

      @api.routes.post '/deploy/new', (req, res) ->
        expect(req.body.repo).to.eql('example-org/example-new-repo')
        expect(req.body.slug).to.eql('example-subdomain')

        res.send
          success: true
          url: 'http://example-subdomain.closeheatapp.com'
          repo_url: 'git@github.com:example-org/example-new-repo.git'

      prompts = [
        {
          question: 'What subdomain would you like'
          answer: 'example-subdomain'
        }
        {
          question: 'How will you name a new GitHub repository'
          answer: 'example-org/example-new-repo'
        }
      ]

      git = '../test/fixtures/git/dist/without_remotes'

      command('publish', prompts: prompts, git: git).then (stdout) ->
        assertStdout stdout,
          """
          TEST: Executing 'git remote --verbose'
          You are about to publish a new website.
          ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) (suggested-slug)
          ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) example-subdomain
          TEST: Executing 'git remote --verbose'
          ? How will you name a new GitHub repository? (example: example-user/example-subdomain)
          ? How will you name a new GitHub repository? (example: example-user/example-subdomain) example-org/example-new-repo
          TEST: Executing 'git remote --verbose'
          TEST: Executing 'git remote add origin git@github.com:example-org/example-new-repo.git'
          #{success('example-org/example-new-repo')}
          """
        done()

    # it 'slug taken', (done) ->
    #   @timeout(5000)
    #
    #   time = 1
    #   @api.routes.post '/deploy/new', (req, res) ->
    #     console.log 'got'
    #     if time == 1
    #       console.log 'got2'
    #       res.send
    #         success: false
    #         error_type: 'slug-exists'
    #         message: 'The subdomain is already taken.'
    #     else
    #       console.log 'got3'
    #       res.send
    #         success: true
    #         url: 'http://example-subdomain.closeheatapp.com'
    #         repo_url: 'git@github.com:example-org/example-new-repo.git'
    #
    #     time = 2
    #
    #   prompts = [
    #     {
    #       question: 'What subdomain would you like'
    #       answer: 'example-subdomain'
    #     }
    #     {
    #       question: 'subdomain would you like'
    #       answer: 'free-subdomain'
    #     }
    #   ]
    #
    #   opts =
    #     prompts: prompts
    #     git: '../test/fixtures/git/dist/default'
    #
    #   command('publish', opts).then (stdout) ->
    #     assertStdout stdout,
    #       """
    #       TEST: Executing 'git remote --verbose'
    #       You are about to publish a new website.
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] (suggested-slug)
    #       ? What subdomain would you like? [example: HELLO.closeheatapp.com] example-subdomain
    #       TEST: Executing 'git remote --verbose'
    #       Using your existing GitHub repository: example-org/example-repo
    #       Subdomain example-subdomain is already taken. Could you choose another one?
    #       TEST: Executing 'git remote --verbose'
    #       #{success('example-org/example-repo')}
    #       """
    #     done()
