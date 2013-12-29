(function() {
  var Tuple, TupleSpace;

  Tuple = require(__dirname + '/tuple');

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name != null ? name : "noname";
      this.tuples = [];
      this.callbacks = [];
      this.__defineGetter__('size', function() {
        return this.tuples.length;
      });
    }

    TupleSpace.prototype.write = function(tuple) {
      var c, called, i, _i, _j, _ref, _ref1;
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      called = [];
      for (i = _i = 0, _ref = this.callbacks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        c = this.callbacks[i];
        if (c.tuple.match(tuple)) {
          called.push(i);
          c.callback(null, tuple);
          if (c.type === 'take') {
            break;
          }
        }
      }
      for (i = _j = 0, _ref1 = called.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        this.callbacks.splice(called[i] - i, 1);
      }
      return this.tuples.push(tuple);
    };

    TupleSpace.prototype.read = function(tuple, callback) {
      var i, id, j, _i, _ref;
      if (typeof callback !== 'function') {
        callback = null;
      }
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        if (callback) {
          callback(null);
        }
        return null;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      for (i = _i = _ref = this.size - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        j = this.tuples[i];
        if (tuple.match(j)) {
          if (callback) {
            callback(null, j);
          }
          return j;
        }
      }
      if (callback) {
        id = new Date - Math.random();
        this.callbacks.push({
          type: 'read',
          callback: callback,
          tuple: tuple,
          id: id
        });
        return id;
      }
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

    TupleSpace.prototype.cancel = function(id) {
      var c, i, _i, _ref, _results;
      _results = [];
      for (i = _i = 0, _ref = this.callbacks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        c = this.callbacks[i];
        if (id === c.id) {
          c.callback("cancel", null);
          _results.push(this.callbacks.splice(i, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return TupleSpace;

  })();

}).call(this);
