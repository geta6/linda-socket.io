## Linda = require('linda-socket.io').Client
Linda = require('../../').Client
socket = require('socket.io-client').connect('http://localhost:3000')

linda = new Linda().connect(socket)
ts = linda.tuplespace('chatroom1')

socket.on 'connect', ->
  console.log 'connect!!!'

  ts.watch {type: "chat"}, (err, tuple) ->
    console.log "> #{tuple.data.message}"

process.stdin.setEncoding 'utf8'
process.stdin.on 'data', (data)->
    ts.write {type: "chat", message: data.replace(/[\r\n]/g, '')}


