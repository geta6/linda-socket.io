(function() {
  var Linda, TupleSpace;

  Linda = (function() {
    function Linda() {}

    Linda.prototype.connect = function(io) {
      this.io = io;
    };

    Linda.prototype.tuplespace = function(name) {
      return new TupleSpace(this.io, name);
    };

    return Linda;

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
      this.io.once("__linda_take_" + id, function(tuple) {
        return callback(null, tuple);
      });
      return this.io.emit('__linda_take', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
    };

    TupleSpace.prototype.read = function(tuple, callback) {
      var id;
      id = this.create_callback_id();
      this.io.once("__linda_read_" + id, function(tuple) {
        return callback(null, tuple);
      });
      return this.io.emit('__linda_read', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
    };

    TupleSpace.prototype.watch = function(tuple, callback) {
      var id;
      id = this.create_callback_id();
      this.io.on("__linda_watch_" + id, function(tuple) {
        return callback(null, tuple);
      });
      return this.io.emit('__linda_watch', {
        tuplespace: this.name,
        tuple: tuple,
        id: id
      });
    };

    return TupleSpace;

  })();

  if (window) {
    window.linda = new Linda;
  } else if (module && module.exports) {
    module.exports = Linda;
  }

}).call(this);
