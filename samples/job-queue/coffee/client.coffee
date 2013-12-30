print = (msg) ->
  $('#log').prepend $('<p>').text(msg)

socket = io.connect("#{location.protocol}//#{location.hostname}")
linda.connect(socket)
ts = linda.tuplespace("calc")

socket.on 'connect', ->
  print "connect!!"
  ts.watch {type: 'result'}, (err, tuple) ->
    print "> #{tuple.data.result}"

jQuery ->
  $('#btn_request').click (e)->
    query = $('#query').val()
    ts.write {type: 'request', query: query}
