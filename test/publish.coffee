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

    TestConfig.init()
    TestConfig.rm()
    Config.update('access_token', 'example-token')

    @api.routes.get '/github-authorized', (req, res) ->
      res.send
        authorized: true

  afterEach ->
    @server.close()

  # TODO: test when
  # ? maybe - .git doesnt exist
  # - git not installed
  # - files already added
  # - files already commited
  # - files already pushed
  # - files already deployed on closeheat

  it 'continuous deployment already configured', (done) ->
    @timeout(5000)

    @api.routes.post '/deploy/slug', (req, res) ->
      res.send
        exists: true
        slug: 'existing-slug'

    command('publish').then (stdout) ->
      assertStdout stdout,
        """
        You are about to publish a new website.
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
      @api.routes.post '/deploy/slug', (req, res) ->
        res.send
          exists: false

      @api.routes.post '/suggest/slug', (req, res) ->
        res.send
          slug: 'suggested-slug'

      @api.routes.post '/free/slug', (req, res) ->
        res.send
          free: true

    describe 'GitHub repo does not exist', ->
      it 'create new repo', (done) ->
        # TODO
        done()

    describe 'GitHub repo already exists', ->
      it 'use existing repo', (done) ->
        @timeout(5000)

        @api.routes.post '/deploy/existing', (req, res) ->
          res.send
            success: true

        prompts = [
          {
            question: 'What subdomain would you like to choose'
            answer: 'example-subdomain'
          }
          {
            question: 'Would you like to use your existing'
            answer: 'y'
          }
        ]

        command('publish', prompts).then (stdout) ->
          assertStdout stdout,
            """
            You are about to publish a new website.
            TEST: Executing 'git remote --verbose'
            ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) (suggested-slug)
            ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) example-subdomain
            TEST: Executing 'git remote --verbose'
            ? Would you like to use your existing example-org/example-repo GitHub repository repo for continuos delivery? (Y/n)
            ? Would you like to use your existing example-org/example-repo GitHub repository repo for continuos delivery? Yes
            #{success('example-org/example-repo')}
            """
          done()

      it 'create new repo', (done) ->
        @timeout(5000)

        @api.routes.post '/deploy/existing', (req, res) ->
          res.send
            success: true

        prompts = [
          {
            question: 'What subdomain would you like to choose'
            answer: 'example-subdomain'
          }
          {
            question: 'Would you like to use your existing'
            answer: 'n'
          }
          {
            question: 'What is the GitHub repository would you like to create for this website?'
            answer: 'example-new-repo'
          }
        ]

        # also add origin to remotes
        command('publish', prompts).then (stdout) ->
          assertStdout stdout,
            """
            You are about to publish a new website.
            TEST: Executing 'git remote --verbose'
            ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) (suggested-slug)
            ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) example-subdomain
            TEST: Executing 'git remote --verbose'
            ? Would you like to use your existing example-org/example-repo GitHub repository repo for continuos delivery? (Y/n)
            ? Would you like to use your existing example-org/example-repo GitHub repository repo for continuos delivery? No
            ? What is the GitHub repository would you like to create for this website? Ex. Nedomas/NAME?
            ? What is the GitHub repository would you like to create for this website? Ex. Nedomas/NAME? example-new-repo
            #{success('example-new-repo')}
            """
          done()
