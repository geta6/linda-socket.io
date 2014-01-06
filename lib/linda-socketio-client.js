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
      this.watch_cids = {};
    }

    TupleSpace.prototype.create_callback_id = function() {
      return Date.now() - Math.random();
    };

    TupleSpace.prototype.create_watch_callback_id = function(tuple) {
      var key;
      key = JSON.stringify(tuple);
      return this.watch_cids[key] || (this.watch_cids[key] = this.create_callback_id());
    };

    TupleSpace.prototype.write = function(tuple, options) {
      var data;
      if (options == null) {
        options = {
          expire: null
        };
      }
      data = {
        tuplespace: this.name,
        tuple: tuple,
        options: options
      };
      return this.io.emit('__linda_write', data);
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
      id = this.create_watch_callback_id(tuple);
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
    window.Linda = LindaClient;
  } else if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = LindaClient;
  }

}).call(this);
