Urls = require './urls'

module.exports =
class Permissions
  @check: (resp) ->
    return unless resp[0]
    return if resp[0].statusCode == 200

    @report(resp[0])

  @report: (resp) ->
    Log = require './log'
    Log.stop()

    Log.error JSON.stringify(resp)
    process.exit()
