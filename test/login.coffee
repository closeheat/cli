nixt = require 'nixt'
fs = require 'fs'
path = require 'path'
expect = require 'expect.js'

closeheat = './dist/bin/closeheat.js'
home_path = path.join(process.cwd(), 'test', 'fixtures', 'home')
config_path = path.join(home_path, '.closeheat', 'config.json')

describe 'login', ->
  describe 'with token', ->
    before ->
      return unless fs.existsSync(config_path)
      fs.unlinkSync(config_path)

    it 'blank slate', (done) ->
      assertConfig = (expected) ->
        ->
          actual = JSON.parse(fs.readFileSync(config_path).toString())
          expect(actual).to.eql(expected)
          done()

      nixt()
        .env('HOME', home_path)
        .run("#{closeheat} login example-token")
        .stdout('- Login successful. Access token saved.')
        .end(assertConfig(access_token: 'example-token'))
