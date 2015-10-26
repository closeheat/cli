expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'

expectGracefulUnauthorized = (stdout) ->
  expect(stdout).to.match(/You need to log in for that./)
  expect(stdout).to.match(/Type/)
  expect(stdout).to.match(/closeheat login/)
  expect(stdout).to.match(/or open/)
  expect(stdout).to.match(/to do it swiftly./)

describe 'graceful when unauthorized', ->
  before ->
    @api = new TestApi()
    @server = @api.start()

  after ->
    @server.close()

  it 'list', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('list').then (stdout) ->
      expect(stdout).to.match(/Getting information about your websites./)
      expectGracefulUnauthorized(stdout)
      done()

  it 'clone', (done) ->
    @api.routes.get '/apps/example-slug', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('clone example-slug').then (stdout) ->
      expect(stdout).to.match(/Getting application data for example-slug./)
      expectGracefulUnauthorized(stdout)
      done()

  describe 'log', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('log').then (stdout) ->
        expect(stdout).to.match(/TEST: Executing 'git remote --verbose'/)
        expectGracefulUnauthorized(stdout)
        done()

    it 'builds unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.send slug: 'example-slug'

      @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('log').then (stdout) ->
        expect(stdout).to.match(/TEST: Executing 'git remote --verbose'/)
        expectGracefulUnauthorized(stdout)
        done()

  it 'open', (done) ->
    @api.routes.post '/deploy/slug', (req, res) ->
      res.status(401).send message: 'Unauthorized'

    command('open').then (stdout) ->
      expect(stdout).to.match(/TEST: Executing 'git remote --verbose'/)
      expectGracefulUnauthorized(stdout)
      done()

  describe 'deploy', ->
    it 'slug unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('deploy').then (stdout) ->
        expect(stdout).to.match(/Deploying the app to closeheat.com via GitHub./)

        # does not execute init since .git exists in cli repo
        expect(stdout).to.match(/TEST: Executing 'git add .'/)
        expect(stdout).to.match(/All files added./)
        expect(stdout).to.match(/Executing 'git commit m: true \'Quick deploy\''/)
        expect(stdout).to.match(/Files commited./)
        expect(stdout).to.match(/Pushing to GitHub./)
        expect(stdout).to.match(/TEST: Executing 'git remote '/)

        # get main branch
        expect(stdout).to.match(/TEST: Executing 'git symbolic-ref --short HEAD'/)
        expect(stdout).to.match(/TEST: Executing 'git push origin example-branch'/)

        expect(stdout).to.match(/Pushed to example-branch branch on GitHub./)

        # start of logs
        expect(stdout).to.match(/TEST: Executing 'git remote --verbose'/)
        expectGracefulUnauthorized(stdout)
        done()

    it 'builds unauthorized', (done) ->
      @timeout(5000)
      @api.routes.post '/deploy/slug', (req, res) ->
        res.send slug: 'example-slug'

      @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
        res.status(401).send message: 'Unauthorized'

      command('deploy').then (stdout) ->
        expect(stdout).to.match(/Deploying the app to closeheat.com via GitHiub./)
        expect(stdout).to.match(/Deploying the app to closeheat.com via GitHub./)

        # does not execute init since .git exists in cli repo
        expect(stdout).to.match(/TEST: Executing 'git add .'/)
        expect(stdout).to.match(/All files added./)
        expect(stdout).to.match(/Executing 'git commit m: true \'Quick deploy\''/)
        expect(stdout).to.match(/Files commited./)
        expect(stdout).to.match(/Pushing to GitHub./)
        expect(stdout).to.match(/TEST: Executing 'git remote '/)

        # get main branch
        expect(stdout).to.match(/TEST: Executing 'git symbolic-ref --short HEAD'/)
        expect(stdout).to.match(/TEST: Executing 'git push origin example-branch'/)

        expect(stdout).to.match(/Pushed to example-branch branch on GitHub./)

        # start of logs
        expect(stdout).to.match(/TEST: Executing 'git remote --verbose'/)
        expectGracefulUnauthorized(stdout)
        done()
