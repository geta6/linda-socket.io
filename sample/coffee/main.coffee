print = (msg) ->
  $('#log').prepend $('<p>').text(msg)

socket = io.connect "#{location.protocol}//#{location.hostname}"
linda.connect socket

socket.on 'connect', ->
  print "connect!!!"
  linda.tuplespace("test").write ["hello", "world"]
