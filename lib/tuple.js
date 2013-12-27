(function() {
  var Tuple;

  module.exports = Tuple = (function() {
    function Tuple(data) {
      this.data = data;
    }

    Tuple.prototype.data = function() {
      return this.data;
    };

    Tuple.prototype.match = function(data) {
      var k, v, _ref;
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
