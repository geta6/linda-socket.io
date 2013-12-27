(function() {
  var Tuple, TupleSpace;

  Tuple = require(__dirname + '/tuple');

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name;
      this.tuples = [];
      this.__defineGetter__('size', function() {
        return this.tuples.length;
      });
    }

    TupleSpace.prototype.write = function(tuple) {
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return;
      }
      return this.tuples.push(tuple);
    };

    TupleSpace.prototype.read = function(tuple) {};

    return TupleSpace;

  })();

}).call(this);
