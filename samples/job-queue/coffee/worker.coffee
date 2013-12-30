print = (msg) ->
  $('#log').prepend $('<p>').text(msg)

socket = io.connect("#{location.protocol}//#{location.hostname}")
linda.connect(socket)
ts = linda.tuplespace("calc")

socket.on 'connect', ->
  print "connect!!"
  work()

work = ->
  ts.take {type: 'request'}, (err, tuple) ->
    result = eval tuple.data.query
    print "#{tuple.data.query} = #{result}"
    ts.write {type: 'result', result: result}
    work()
