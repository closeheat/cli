expect = require('chai').expect

Config = require '../src/config'
command = require './helpers/command'
TestApi = require './helpers/test_api'

describe 'clone', ->
  describe 'authorized', ->
    beforeEach ->
      @api = new TestApi()
      @server = @api.start()

    afterEach ->
      @server.close()

    it 'without app name should show apps list', (done) ->
      @api.routes.get '/apps', (req, res) ->
        res.send apps: [
          {
            name: 'Example app',
            slug: 'example-slug',
          }
        ]

      command('clone').then (stdout) ->
        expect(stdout).to.match(/Getting information about your deployed apps./)
        expect(stdout).to.match(/You have 1 apps deployed./)
        expect(stdout).to.match(/Name/)
        expect(stdout).to.match(/Clone command/)
        expect(stdout).to.match(/Example app/)
        expect(stdout).to.match(/closeheat clone example-slug/)
        expect(stdout).to.match(/Edit any of your apps by cloning it with:/)
        expect(stdout).to.match(/closeheat clone your-awesome-app/)
        done()

    it 'with app name', (done) ->
      @api.routes.get '/apps/example-slug', (req, res) ->
        res.send
          app:
            github_repo: 'example/repo'
            default_branch: 'example-branch'
            slug: 'example-slug'

      command('clone example-slug').then (stdout) ->
        expect(stdout).to.match(/Getting application data for example-slug./)
        expect(stdout).to.match(/Cloning GitHub repository from example\/repo./)
        expect(stdout).to.match(/Cloned the app code to directory 'example-slug'/)
        done()

    it 'with invalid app name', (done) ->
      @timeout(5000)
      @api.routes.get '/apps/example-slug', (req, res) ->
        res.send 'BAD RESPONSE'

      command('clone example-slug').then (stdout) ->
        expect(stdout).to.match(/does not exist./)
        done()
