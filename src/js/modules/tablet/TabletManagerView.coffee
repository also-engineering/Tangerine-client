TabletManagerView = Backbone.View.extend

  className : "TabletManagerView"

  events:
    'click .start' : 'start'
    'click .stop' : 'stop'

  send: (ip, data) ->
    console.log("sending to #{ip}")
    console.log(data)
    if @sockets[ip]
      @sockets[ip].send JSON.stringify data
    else
      (new WebSocket("ws://#{ip}:6569"))
        .onopen = (e) =>
          socket = e.currentTarget
          @sockets[ip] = socket
          socket.send JSON.stringify data

  search: ->
    [100..150].forEach (i) =>
      (new WebSocket("ws://192.168.0." + i + ":6569"))
        .onopen = (e) =>
          socket = e.currentTarget
          a = document.createElement("a")
          a.href = socket.url
          ip = a.hostname
          @sockets[ip] = socket
          @introduce ip

  introduce: (ip) ->
    @send ip,
      type: "intro"
      name: Tangerine.user.name()

  sendFriends: (ip) ->
    @updateStatus ip, "sending friends"
    @send ip,
      type: "friends"
      clients: @clients

  removeClient: (ip) ->
    delete @clients[ip]
    @updateClients()

  addClient: ( ip, name ) ->
    @clients[ip] = {
      name: name
      status: "new"
    }
    @updateClients()

  updateStatus: (ip, status) ->
    @clients[ip].status = status
    @updateClients()

  addClients: (theirClients) ->
    myClientIps = Object.keys(@clients)
    Object.keys(theirClients).forEach (ip) =>
      if myClientIps.indexOf(ip) == -1
        @addClient ip, theirClients[ip].name

  updateClients: ->
    @$el.find("#clients").html "
      <tr><th>Name</th><th>Status</th></tr>
      #{Object.keys(@clients).map((client) =>
        "<tr><td>#{@clients[client].name}</td><td>#{@clients[client].status}</td></tr>"
      ).join(", ")}
    "
  offer: (options={}) ->
    options.exclude = '' unless options.exclude
    Tangerine.db.query('tangerine/byCollection',{keys:['result']})
      .then (res) =>
        console.log("checking for offerables")
        console.log(res)
        ids = res.rows.map (row) -> row.id
        Object.keys(@clients).forEach (ip) =>
          return if ip is options.exclude
          @updateStatus ip, "offering docs"
          @send ip,
            type: "offer"
            ids : ids

  checkIds: (ip, theirIds) ->
    console.log "checking ids"
    console.log theirIds
    Tangerine.db.query('tangerine/byCollection',{keys:['result']})
      .then (res) =>
        ids = res.rows.map (row) -> row.id
        newIds = theirIds.filter (el) -> ids.indexOf(el) == -1
        @updateStatus ip, "requesting #{newIds.length} results"
        @send ip,
          type: 'request'
          ids: newIds

  deliver: (ip, ids) ->
    console.log "got a delivery"
    console.log ids
    if ids.length is 0
      @updateStatus ip, "Done"
      return @count ip
    Tangerine.db.allDocs({keys:ids,include_docs: true})
      .then (res) =>
        docs = res.rows.map (row) -> row.doc
        @updateStatus ip, "sending documents"
        @send ip,
          type: 'delivery'
          docs: docs

  addDocs: (ip, docs) ->
    Tangerine.db.bulkDocs(docs)
      .then (res) =>
        console.log(res)
        @count ip
      .catch =>
        @count ip

  count: (ip) ->
    Tangerine.db.query('tangerine/byCollection',{keys:['result']})
      .then (res) =>
        console.log(res)
        @$el.find("#result-count").html res.rows.length
        @send ip,
          type: "count"
          count : count

  updateCount: (ip, count) ->
    @updateStatus ip, "Done. #{count} results."

  initialize: ->
    @sockets = {}
    @clients = {}
    @knownIps = []

  start: ->
    @server = cordova?.plugins?.wsserver
    @server.stop()
    @server.start 6569,
      onStart : (addr, port) =>
        console.log('Listening on %s:%d', addr, port)
        @search()
      onMessage : (conn, msg) =>
        obj = JSON.parse(msg)
        ip = conn.remoteAddr
        console.log("from #{ip}")
        console.log(obj)
        if obj.type is "intro"
          @addClient ip, obj.name
          @sendFriends ip
          @offer()
        else if obj.type is "friends"
          @addClients obj.clients
          @offer
            exclude: ip
        else if obj.type is "offer"
          @checkIds ip, obj.ids
        else if obj.type is "request"
          @deliver ip, obj.ids
        else if obj.type is "delivery"
          @addDocs ip, obj.docs
        else if obj.type is "count"
          @updateCount ip, obj.count


      onClose : (conn) =>
        @removeClient conn.remoteAddr

  stop: ->
    console.log("closing server")
    @server.stop()

  onClose: ->
    console.log("closing server")
    @stop()

  render: ->

    @$el.html "
      <h1>Sync manager</h1>
      <button class='start command'>Start</button>
      <button class='stop command'>Stop</button>
      <section>
        Total results: <span id='result-count'></span>
      </section>
      <section>
        <h2>Tablets</h2>
        <table id='clients'></table>
      </section>
    "