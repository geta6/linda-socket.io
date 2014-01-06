(function() {
  var Tuple, TupleSpace, path;

  path = require('path');

  Tuple = require(path.resolve('lib', 'tuple'));

  module.exports = TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name != null ? name : 'noname';
      this.tuples = [];
      this.callbacks = [];
      this.__defineGetter__('size', function() {
        return this.tuples.length;
      });
    }

    TupleSpace.prototype.write = function(tuple, options) {
      var c, called, i, taked, _i, _j, _ref;
      if (options == null) {
        options = {
          expire: Tuple.DEFAULT.expire
        };
      }
      if (!Tuple.isHash(tuple) && !(tuple instanceof Tuple)) {
        return;
      }
      if (!(tuple instanceof Tuple)) {
        tuple = new Tuple(tuple);
      }
      tuple.expire = typeof options.expire === 'number' && options.expire > 0 ? options.expire : Tuple.DEFAULT.expire;
      called = [];
      taked = false;
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
          })(c);
          if (c.type === 'take') {
            taked = true;
            break;
          }
        }
      }
      for (_j = called.length - 1; _j >= 0; _j += -1) {
        i = called[_j];
        this.callbacks.splice(i, 1);
      }
      if (!taked) {
        return this.tuples.push(tuple);
      }
    };

    TupleSpace.prototype.create_callback_id = function() {
      return Date.now() - Math.random();
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
        id = this.create_callback_id();
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
        id = this.create_callback_id();
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
      id = this.create_callback_id();
      this.callbacks.unshift({
        id: id,
        type: 'watch',
        tuple: tuple,
        callback: callback
      });
      return id;
    };

    TupleSpace.prototype.cancel = function(id) {
      var c, i, _i, _ref;
      if (id == null) {
        return;
      }
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

    TupleSpace.prototype.check_expire = function() {
      var expires, i, _i, _j, _ref;
      expires = [];
      for (i = _i = 0, _ref = this.tuples.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (this.tuples[i].expire_at < Date.now() / 1000) {
          expires.push(i);
        }
      }
      for (_j = expires.length - 1; _j >= 0; _j += -1) {
        i = expires[_j];
        this.tuples.splice(i, 1);
      }
      return expires.length;
    };

    return TupleSpace;

  })();

}).call(this);
