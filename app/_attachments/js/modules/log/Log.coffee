# this object forces itself to be a singleton
class Log extends Backbone.Model

  url: "log"

  initialize: ->
    @ensure()

  #
  # Log using these four functions
  #

  # larger application functions
  app: ( code = "", details = "" ) ->
    if ~Tangerine.settings.get("log").indexOf("app")
      @ensure =>
        Tangerine.log.add
          "type"      : "app"
          "code"      : code
          "details"   : details
          "timestamp" : (new Date()).getTime()

  # communications with databases
  db: ( code = "", details = "" ) ->
    if ~Tangerine.settings.get("log").indexOf("db")
      @ensure =>
        Tangerine.log.add
          "type"      : "db"
          "code"      : code
          "details"   : details
          "timestamp" : (new Date()).getTime()

  # specific UI interactions
  ui: ( code = "", details = "" ) ->
    if ~Tangerine.settings.get("log").indexOf("ui")
      @ensure =>
        Tangerine.log.add
          "type"      : "ui"
          "code"      : code
          "details"   : details
          "timestamp" : (new Date()).getTime()

  # errors, handled or otherwise
  err: ( code = "", details = "" ) ->
    if ~Tangerine.settings.get("log").indexOf("err")
      @ensure =>
        Tangerine.log.add
          "type"      : "err"
          "code"      : code
          "details"   : details
          "timestamp" : (new Date()).getTime()


  # forces singularity, then saves
  ensure: ( callback={} ) ->
    # I have a name that changes every hour
    desiredId = @calcFileName()

    # do we already have a log going?
    if not Tangerine.log?
      # NO, no log yet. See if one exists on the server
      Tangerine.log = @
      Tangerine.log.set "_id" : desiredId
      Tangerine.log.fetch
        success: (model, response, options) =>
          # it was there, we updated ourselves, time to save
          callback?()
        error: (model, xhr, options ) =>
          # it wasna't there, let's start with this one
          @save
            success:=>
              callback?()
    else
      # YES, check to see if it's current
      if Tangerine.log.id == desiredId
        # YES, already existing log is current
        callback?()
      else
        # NO, it's old, make a new one
        Tangerine.log = @
        # Now it's current
        callback?()

  # requires that THIS, @, is up to date. 
  # has a side effect, it saves
  add: ( logEvent ) ->

    d = new Date()

    @set "year",  d.getFullYear()     if not @has("year")
    @set "month", d.getMonth()        if not @has("month")
    @set "date",  d.getDate()         if not @has("date")
    @set "user",  Tangerine.user.name if not @has("user")

    logEvents = @getArray("logEvents")
    logEvents.push logEvent
    @set "logEvents", logEvents
    @save()

  calcFileName: ->
    d = new Date()
    user = if Tangerine.user.name? then Tangerine.user.name else "not-signed-in"
    return hex_sha1 "#{user}_#{d.getFullYear()}-#{d.getMonth()}-#{d.getDate()}"

class Logs extends Backbone.Collection
  url: "log"
  model: Log
  comparator: (model) -> return model.get "timestamp"

class LogView extends Backbone.View

  initialize: (options) ->
    @logs = options.logs.models

  render: ->

    html = ""
    for log in @logs
      for k, v of log.attributes
        continue if k in ["_rev", "_id", "collection", "hash", "updated", "logEvents"] 
        html += "<b>#{k}</b> #{v}<br><br>"
      for oneEvent in log.attributes.logEvents
        for k, v of oneEvent
          if k == "timestamp" then v = (new Date(parseInt(v))).toString()
          html += "<b>#{k}</b> #{v}<br>"
        html += "<br>"

    @$el.html html
    
    @trigger "rendered"
