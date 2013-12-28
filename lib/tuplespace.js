(function() {
  var Tuple, TupleSpace;

  Tuple = require(__dirname + '/tuple');

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name != null ? name : "noname";
      this.tuples = [];
      this.__defineGetter__('size', function() {
        return this.tuples.length;
      });
    }

    TupleSpace.prototype.write = function(tuple) {
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      return this.tuples.push(tuple);
    };

    TupleSpace.prototype.read = function(tuple) {
      var i, j, _i, _ref;
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return null;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      for (i = _i = _ref = this.size - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        j = this.tuples[i];
        if (tuple.match(j)) {
          return j;
        }
      }
      return null;
    };

    TupleSpace.prototype.take = function(tuple) {
      var i, j, _i, _ref;
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return null;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      for (i = _i = _ref = this.size - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        j = this.tuples[i];
        if (tuple.match(j)) {
          this.tuples.splice(i, 1);
          return j;
        }
      }
      return null;
    };

    return TupleSpace;

  })();

}).call(this);
