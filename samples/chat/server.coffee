http = require 'http'
fs   = require 'fs'
url  = require 'url'

app_handler = (req, res) ->
  _url = url.parse(decodeURI(req.url), true);
  path = if _url.pathname == '/' then '/index.html' else _url.pathname
  console.log "#{req.method} - #{path}"
  fs.readFile __dirname+path, (err, data) ->
    if err
      res.writeHead 500
      return res.end 'error load file'
    res.writeHead 200
    res.end data

app = http.createServer(app_handler)
io = require('socket.io').listen(app)
io.configure 'development', ->
  io.set 'log level', 2


## linda = require('linda-socket.io').Linda.listen(io: io, server: app)
linda = require('../../').Linda.listen(io: io, server: app)
linda.on 'write', (data) ->
  console.log "write tuple - #{JSON.stringify data}"

linda.on 'watch', (data) ->
  console.log "watch tuple - #{JSON.stringify data}"

port = process.argv[2]-0 || 3000
app.listen port
console.log "server start - port:#{port}"
