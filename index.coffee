Twit = require 'twit'
Hapi = require 'hapi'
SocketIO = require 'socket.io'

T = new Twit
  consumer_key: process.env.API_KEY
  consumer_secret: process.env.API_SECRET
  access_token: process.env.ACCESS_TOKEN
  access_token_secret: process.env.ACCESS_TOKEN_SECRET

server = Hapi.createServer '0.0.0.0', process.env.PORT || 8080, {}

server.route
    method: 'GET',
    path: '/{path*}',
    handler:
      directory:
        path: "./public"
        listing: false
        index: true

# Start the server
server.start ->
  console.log "Hapi server started at " + server.info.uri
  server.websocket = SocketIO.listen server.listener, log: false

  context =
    filter: ''
    stream: null
  server.websocket.on 'connection', (socket) ->
    # Emit to clients new clients count.
    server.websocket.emit 'clientsCount', server.websocket.engine.clientsCount

    # Send to new client what the current filter is if any.
    socket.emit 'newFilter', context.filter

    # When the client disconnects, send to remaining clients the new clients count.
    socket.on 'disconnect', ->
      server.websocket.emit 'clientsCount', server.websocket.engine.clientsCount

    # Client sent a new filter.
    socket.on 'newFilter', (filter) ->
      context.filter = filter

      # Inform all listeners that the filter changed.
      server.websocket.emit('newFilter', filter)

      # Stop the active stream (if there is one).
      if context.stream?
        old = context.stream
        old.stop()

      # Create new twitter stream with the new filter.
      context.stream = T.stream('statuses/filter', track: filter)
      context.stream.on 'tweet', (tweet) ->
        server.websocket.emit 'tweet', tweet
