(function() {
  var Linda, TupleSpace, linda;

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

    TupleSpace.prototype.write = function(tuple) {
      return this.io.emit('__linda_write', {
        tuplespace: this.name,
        tuple: tuple
      });
    };

    return TupleSpace;

  })();

  linda = new Linda;

}).call(this);
