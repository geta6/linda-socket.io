(function() {
  var print, socket, ts;

  print = function(msg) {
    return $('#log').prepend($('<p>').text(msg));
  };

  socket = io.connect("" + location.protocol + "//" + location.hostname);

  linda.connect(socket);

  ts = linda.tuplespace("test");

  socket.on('connect', function() {
    return print("connect!!!");
  });

  ts.watch({
    type: "chat"
  }, function(err, tuple) {
    return print("> " + tuple.data.message);
  });

  jQuery(function() {
    return $('#btn_send').click(function(e) {
      var msg;
      msg = $('#msg_body').val();
      return ts.write({
        type: "chat",
        message: msg
      });
    });
  });

}).call(this);
