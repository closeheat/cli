expect = require('chai').expect

command = require './helpers/command'
assertStdout = require './helpers/assert_stdout'
TestApi = require './helpers/test_api'

describe 'publish', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  # TODO: test when
  # - .git doesnt exist
  # - files already added
  # - files already commited
  # - files already pushed
  # - files already deployed on closeheat
  # it 'GitHub unauthorized', (done) ->
  #   @timeout(5000)
  #   @api.routes.get '/github-authorized', (req, res) ->
  #     res.send
  #       authorized: false
  #
  #   command('publish').then (stdout) ->
  #     assertStdout stdout,
  #       """
  #       You are about to publish a new website.
  #       ERROR | GitHub not authorized
  #               We cannot set you up for deployment because you did not authorize GitHub.
  #               Visit http://app.closeheat.com/authorize-github and rerun the command.
  #       """
  #     done()

  # it 'GitHub authorized and app exists', (done) ->
  #   @timeout(5000)
  #   @api.routes.get '/github-authorized', (req, res) ->
  #     res.send
  #       authorized: true
  #
  #   @api.routes.post '/deploy/slug', (req, res) ->
  #     res.send
  #       exists: true
  #       slug: 'existing-slug'
  #
  #   command('publish').then (stdout) ->
  #     assertStdout stdout,
  #       """
  #       You are about to publish a new website.
  #       TEST: Executing 'git remote --verbose'
  #       Hey there! This folder is already published to closeheat.
  #       It is available at existing-slug.closeheatapp.com.
  #       You can open it swiftly by typing closeheat open.
  #       It has a continuous deployment setup from GitHub at example-org/example-repo
  #       Anyways - if you'd like to publish your current code changes, just type:
  #       closeheat quick-publish
  #       Doing that will commit and push all of your changes to the GitHub repository and publish it.
  #       """
  #     done()

  it 'GitHub authorized and app doesnt exist', (done) ->
    @timeout(5000)
    @api.routes.get '/github-authorized', (req, res) ->
      res.send
        authorized: true

    @api.routes.post '/deploy/slug', (req, res) ->
      res.send
        exists: false

    @api.routes.post '/suggest/slug', (req, res) ->
      res.send
        slug: 'hello'

    prompts = [
      {
        question: 'What subdomain'
        answer: 'example-subdomain'
      }
    ]

    command('publish', prompts).then (stdout) ->
      assertStdout stdout,
        """
        You are about to publish a new website.
        TEST: Executing 'git remote --verbose'
        ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) (hello)
        ? What subdomain would you like to choose at SUBDOMAIN.closeheatapp.com? (you will be able to add top level domain later) example-subdomain
        It is available at existing-slug.closeheatapp.com.
        You can open it swiftly by typing closeheat open.
        It has a continuous deployment setup from GitHub at example-org/example-repo
        Anyways - if you'd like to publish your current code changes, just type:
        closeheat quick-publish
        Doing that will commit and push all of your changes to the GitHub repository and publish it.
        """
      done()
