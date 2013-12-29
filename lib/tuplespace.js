(function() {
  var Tuple, TupleSpace;

  Tuple = require(__dirname + '/tuple');

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name != null ? name : 'noname';
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
          if (c.type === 'take' || c.type === 'read') {
            called.push(i);
          }
          (function(c) {
            return setImmediate(function() {
              return c.callback(null, tuple);
            });
          }).call(this, c);
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
      var i, id, t, _i, _ref;
      if (typeof callback !== 'function') {
        callback = null;
      }
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        if (callback) {
          setImmediate(function() {
            return callback('argument_error');
          });
        }
        return null;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      for (i = _i = _ref = this.size - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        t = this.tuples[i];
        if (tuple.match(t)) {
          if (callback) {
            setImmediate(function() {
              return callback(null, t);
            });
          }
          return t;
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

    TupleSpace.prototype.take = function(tuple, callback) {
      var i, id, t, _i, _ref;
      if (typeof callback !== 'function') {
        callback = null;
      }
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        if (callback) {
          setImmediate(function() {
            return callback('argument_error');
          });
        }
        return null;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      for (i = _i = _ref = this.size - 1; _ref <= 0 ? _i <= 0 : _i >= 0; i = _ref <= 0 ? ++_i : --_i) {
        t = this.tuples[i];
        if (tuple.match(t)) {
          if (callback) {
            setImmediate(function() {
              return callback(null, t);
            });
          }
          this.tuples.splice(i, 1);
          return t;
        }
      }
      if (callback) {
        id = new Date - Math.random();
        this.callbacks.push({
          type: 'take',
          callback: callback,
          tuple: tuple,
          id: id
        });
        return id;
      }
    };

    TupleSpace.prototype.watch = function(tuple, callback) {
      var id;
      if (typeof callback !== 'function') {
        return;
      }
      if (!Tuple.isHash(tuple) && !(tuple(instance(Tuple)))) {
        setImmediate(function() {
          return callback('argument_error');
        });
        return;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      id = new Date - Math.random();
      this.callbacks.unshift({
        type: 'watch',
        callback: callback,
        tuple: tuple,
        id: id
      });
      return id;
    };

    TupleSpace.prototype.cancel = function(id) {
      var c, i, _i, _ref;
      for (i = _i = 0, _ref = this.callbacks.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        c = this.callbacks[i];
        if (id === c.id) {
          setImmediate(function() {
            return c.callback('cancel', null);
          });
          this.callbacks.splice(i, 1);
          return;
        }
      }
    };

    return TupleSpace;

  })();

}).call(this);
