## Linda = require('linda-socket.io').Client
LindaClient = require('../../').Client
socket = require('socket.io-client').connect('http://localhost:3000')

linda = new LindaClient().connect(socket)
ts = linda.tuplespace('calc')

socket.on 'connect', ->
  console.log 'connect!!!'
  work()

work = ->
  ts.take {type: 'request'}, (err, tuple) ->
    result = eval tuple.data.query
    console.log "#{tuple.data.query} = #{result}"
    ts.write {type: 'result', result: result}
    work()

