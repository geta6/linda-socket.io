http = require 'http'
url  = require 'url'
fs = require 'fs'
events = require 'events'
socketio = require 'socket.io'

TupleSpace = module.exports.TupleSpace = require __dirname+'/tuplespace'
Tuple = module.exports.Tuple = require __dirname+'/tuple'
module.exports.Client = require __dirname+'/linda-socketio-client'

class Linda extends events.EventEmitter
  constructor: ->
    @spaces = {}

    fs.readFile __dirname+"/linda-socketio-client.js", (err, data) =>
      throw new Error "client js load error" if err
      @client_js_code = data

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

    @server.on 'request', (req, res) =>
      _url = url.parse(decodeURI(req.url), true)
      if _url.pathname == "/linda/linda-socket.io.js"
        res.writeHead 200
        res.end @client_js_code

    @io.sockets.on 'connection', (socket) =>
      cids = {}

      socket.on '__linda_write', (data) =>
        @tuplespace(data.tuplespace).write data.tuple
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

      socket.on '__linda_watch', (data) =>
        cid = @tuplespace(data.tuplespace).watch data.tuple, (err, tuple) ->
          socket.emit "__linda_watch_#{data.id}", err, tuple
        cids[data.id] = cid
        @emit 'watch', data
        socket.once 'disconnect', =>
          @tuplespace(data.tuplespace).cancel cid if cid

      socket.on '__linda_cancel', (data) =>
        @tuplespace(data.tuplespace).cancel cids[data.id]

    return @


module.exports.Linda = new Linda
