expect = require('chai').expect

TestApi = require './helpers/test_api'
command = require './helpers/command'

describe 'list', ->
  beforeEach ->
    @api = new TestApi()
    @server = @api.start()

  afterEach ->
    @server.close()

  it 'should show one website and instructions', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.send apps: [
        {
          name: 'Example app',
          slug: 'example-slug',
        }
      ]

    command('list').then (stdout) ->
      expect(stdout).to.match(/Getting information about your websites./)
      expect(stdout).to.match(/You have 1 websites./)
      expect(stdout).to.match(/Name/)
      expect(stdout).to.match(/Clone command/)
      expect(stdout).to.match(/Example app/)
      expect(stdout).to.match(/closeheat clone example-slug/)
      expect(stdout).to.match(/Edit any of your websites by cloning it with:/)
      expect(stdout).to.match(/closeheat clone awesome-website/)
      done()

  it 'should show deploy instructions when no websites', (done) ->
    @api.routes.get '/apps', (req, res) ->
      res.send apps: []

    command('list').then (stdout) ->
      expect(stdout).to.match(/You have no websites./)
      expect(stdout).to.match(/Publish this folder as a website by typing:/)
      expect(stdout).to.match(/closeheat deploy your-website-name/)
      done()
