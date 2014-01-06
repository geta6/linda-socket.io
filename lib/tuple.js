(function() {
  var Tuple;

  module.exports = Tuple = (function() {
    Tuple.isHash = function(data) {
      if (!data || data instanceof Array || typeof data !== "object") {
        return false;
      }
      return true;
    };

    Tuple.DEFAULT = {
      expire: 300
    };

    function Tuple(data) {
      this.data = data;
      this.__defineSetter__('expire', function(sec) {
        return this.expire_at = Math.floor(Date.now() / 1000) + sec;
      });
      this.expire = 300;
    }

    Tuple.prototype.match = function(tuple) {
      var data, k, v, _ref;
      if (!Tuple.isHash(tuple)) {
        return false;
      }
      data = tuple instanceof Tuple ? tuple.data : tuple;
      _ref = this.data;
      for (k in _ref) {
        v = _ref[k];
        if (typeof v === 'object') {
          if (typeof data[k] !== 'object') {
            return false;
          }
          if (JSON.stringify(v) !== JSON.stringify(data[k])) {
            return false;
          }
        } else {
          if (v !== data[k]) {
            return false;
          }
        }
      }
      return true;
    };

    return Tuple;

  })();

}).call(this);
