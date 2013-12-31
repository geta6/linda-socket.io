print = (msg) ->
  $('#log').prepend $('<p>').text(msg)

socket = io.connect("#{location.protocol}//#{location.hostname}")

linda = new Linda().connect(socket)
ts = linda.tuplespace("chatroom1")

socket.on 'connect', ->
  print "connect!!!"

  ts.watch {type: "chat"}, (err, tuple) ->
    print "> #{tuple.data.message}"

jQuery ->
  $('#btn_send').click (e)->
    msg = $('#msg_body').val()
    ts.write {type: "chat", message: msg}
