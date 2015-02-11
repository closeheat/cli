module.exports =
class Urls

  @appData: (app_name) ->
    "#{@appsIndex()}/#{app_name}"

  @appsIndex: ->
    'http://staging.closeheat.com/api/apps'
    # 'http://10.30.0.1:4000/api/apps'
