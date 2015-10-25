expect = require('chai').expect

command = require './helpers/command'
TestApi = require './helpers/test_api'

describe 'deploy', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  it 'should push to GitHub and display deploy log', (done) ->
    @timeout(5000)
    @api.routes.post '/deploy/slug', (req, res) ->
      res.send slug: 'example-slug'

    @api.routes.get '/apps/example-slug/builds/for_cli', (req, res) ->
      res.send
        build:
          status: 'success'
          log: [
            {
              message: 'Testing logs.'
            }
          ]

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
      expect(stdout).to.match(/closeheat | Testing logs./)
      done()
