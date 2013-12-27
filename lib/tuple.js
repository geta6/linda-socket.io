(function() {
  var Tuple;

  module.exports = Tuple = (function() {
    function Tuple(data) {
      this.data = data;
    }

    Tuple.prototype.data = function() {
      return this.data;
    };

    Tuple.prototype.match = function(tuple) {
      var data, k, v, _ref;
      if (tuple instanceof Array || typeof tuple !== "object") {
        return false;
      }
      data = tuple instanceof Tuple ? tuple.data : tuple;
      _ref = this.data;
      for (k in _ref) {
        v = _ref[k];
        if (v !== data[k]) {
          return false;
        }
      }
      return true;
    };

    return Tuple;

  })();

}).call(this);
