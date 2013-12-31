(function() {
  var LindaClient, TupleSpace;

  LindaClient = (function() {
    function LindaClient() {}

    LindaClient.prototype.connect = function(io) {
      this.io = io;
      return this;
    };

    LindaClient.prototype.tuplespace = function(name) {
      return new TupleSpace(this.io, name);
    };

    return LindaClient;

  })();

  TupleSpace = (function() {
    function TupleSpace(io, name) {
      this.io = io;
      this.name = name;
    }

    TupleSpace.prototype.create_callback_id = function() {
      return new Date() - Math.random();
    };

    TupleSpace.prototype.write = function(tuple) {
      return this.io.emit('__linda_write', {
        tuplespace: this.name,
        tuple: tuple
      });
    };

    TupleSpace.prototype.take = function(tuple, callback) {
      var id;
      id = this.create_callback_id();
      this.io.once("__linda_take_" + id, function(err, tuple) {
        return callback(err, tuple);
      });
      this.io.emit('__linda_take', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
      return id;
    };

    TupleSpace.prototype.read = function(tuple, callback) {
      var id;
      id = this.create_callback_id();
      this.io.once("__linda_read_" + id, function(err, tuple) {
        return callback(err, tuple);
      });
      this.io.emit('__linda_read', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
      return id;
    };

    TupleSpace.prototype.watch = function(tuple, callback) {
      var id;
      id = this.create_callback_id();
      this.io.on("__linda_watch_" + id, function(err, tuple) {
        return callback(err, tuple);
      });
      this.io.emit('__linda_watch', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
      return id;
    };

    TupleSpace.prototype.cancel = function(id) {
      return this.io.emit('__linda_cancel', {
        tuplespace: this.name,
        id: id
      });
    };

    return TupleSpace;

  })();

  if (typeof window !== "undefined" && window !== null) {
    window.linda = new LindaClient;
  } else if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = LindaClient;
  }

}).call(this);
