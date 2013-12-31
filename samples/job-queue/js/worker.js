(function() {
  var linda, print, socket, ts, work;

  print = function(msg) {
    return $('#log').prepend($('<p>').text(msg));
  };

  socket = io.connect("" + location.protocol + "//" + location.hostname);

  linda = new Linda().connect(socket);

  ts = linda.tuplespace("calc");

  socket.on('connect', function() {
    print("connect!!");
    return work();
  });

  work = function() {
    return ts.take({
      type: 'request'
    }, function(err, tuple) {
      var result;
      result = eval(tuple.data.query);
      print("" + tuple.data.query + " = " + result);
      ts.write({
        type: 'result',
        result: result
      });
      return work();
    });
  };

}).call(this);
