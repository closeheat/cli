Urls = require './urls'

module.exports =
class Errors
  @check: (resp) ->
    return unless resp[0]
    return if resp[0].statusCode == 200

    @report(resp[0])

  @report: (resp) ->
    Log = require './log'
    Log.stop()

    switch resp.body.type
      when 'app-not-found'
        # TODO: add what to do then
        Log.p("Could not find this website.")
      else
        Log.error JSON.stringify(resp)

    process.exit()
