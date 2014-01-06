http = require 'http'
path = require 'path'
url  = require 'url'
fs = require 'fs'
events = require 'eventemitter2'
socketio = require 'socket.io'

TupleSpace = require path.resolve 'lib', 'tuplespace'
Tuple = require path.resolve 'lib', 'tuple'
Client = require path.resolve 'lib', 'linda-socketio-client'

module.exports.TupleSpace = TupleSpace
module.exports.Tuple = Tuple
module.exports.Client = Client

class Linda extends events.EventEmitter2
  constructor: ->
    @spaces = {}

    fs.readFile path.resolve('lib', 'linda-socketio-client.js'), (err, data) =>
      throw new Error "client js load error" if err
      @client_js_code = data

    setInterval =>
      for name, space of @spaces
        if space?
          space.check_expire()
    , 60*3*1000 # 3min

  tuplespace: (name) ->
    return @spaces[name] ||
           @spaces[name] = new TupleSpace(name)

  listen: (opts = {io: null, server: null}) ->
    unless opts.io?
      throw new Error '"io" must be instance of Socket.IO'
    unless opts.server instanceof http.Server
      throw new Error '"server" must be instance of http.Server'
    @io = opts.io
    @server = opts.server

    @oldListeners = @server.listeners('request').splice(0)
    @server.removeAllListeners 'request'
    @server.on 'request', (req, res) =>  ## intercept requests
      _url = url.parse(decodeURI(req.url), true)
      if _url.pathname == "/linda/linda-socket.io.js"
        res.writeHead 200
        res.end @client_js_code
        return
      for listener in @oldListeners
        listener.call(@server, req, res)

    @io.sockets.on 'connection', (socket) =>
      cids = {}

      socket.on '__linda_write', (data) =>
        @tuplespace(data.tuplespace).write data.tuple, data.options
        @.emit 'write', data

      socket.on '__linda_take', (data) =>
        cid = @tuplespace(data.tuplespace).take data.tuple, (err, tuple) ->
          cid = null
          socket.emit "__linda_take_#{data.id}", err, tuple
        cids[data.id] = cid
        @.emit 'take', data
        socket.once 'disconnect', =>
          @tuplespace(data.tuplespace).cancel cid if cid

      socket.on '__linda_read', (data) =>
        cid = @tuplespace(data.tuplespace).read data.tuple, (err, tuple) ->
          cid = null
          socket.emit "__linda_read_#{data.id}", err, tuple
        cids[data.id] = cid
        @.emit 'read', data
        socket.once 'disconnect', =>
          @tuplespace(data.tuplespace).cancel cid if cid

      watch_cids = {}
      socket.on '__linda_watch', (data) =>
        return if watch_cids[data.id]  # not watch if already watching
        watch_cids[data.id] = true
        cid = @tuplespace(data.tuplespace).watch data.tuple, (err, tuple) ->
          socket.emit "__linda_watch_#{data.id}", err, tuple
        cids[data.id] = cid
        @emit 'watch', data
        socket.once 'disconnect', =>
          @tuplespace(data.tuplespace).cancel cid if cid

      socket.on '__linda_cancel', (data) =>
        @tuplespace(data.tuplespace).cancel cids[data.id]
        watch_cids[data.id] = false

    return @


module.exports.Linda = new Linda
