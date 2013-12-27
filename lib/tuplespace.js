(function() {
  var TupleSpace;

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name;
      this.tuples = [];
      this.__defineGetter__('size', function() {
        return this.tuples.length;
      });
    }

    TupleSpace.prototype.write = function(tuple) {
      this.tuples.push(tuple);
      return true;
    };

    return TupleSpace;

  })();

}).call(this);
