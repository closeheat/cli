Log = require './log'
_ = require 'lodash'

module.exports =
class BackendLogger
  constructor: ->
    @old_log = []
    @try = 0
    @last_status = 'none'

  log: (build) ->
    _.each @diff(build), Log.backend

    @old_log = build.log
    @checkTimeout(build)

  checkTimeout: (build) ->
    if build.status == @status
      Log.error 'Deployment timed out.' if @try > 10
      @try += 1
    else
      @last_status = build.status

  diff: (build) ->
    _.select build.log, (new_data) =>
      !_.contains(_.map(@old_log, 'message'), new_data.message)
