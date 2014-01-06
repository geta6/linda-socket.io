(function() {
  var Client, Linda, Tuple, TupleSpace, events, fs, http, path, socketio, url,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  http = require('http');

  path = require('path');

  url = require('url');

  fs = require('fs');

  events = require('eventemitter2');

  socketio = require('socket.io');

  TupleSpace = require(path.resolve('lib', 'tuplespace'));

  Tuple = require(path.resolve('lib', 'tuple'));

  Client = require(path.resolve('lib', 'linda-socketio-client'));

  module.exports.TupleSpace = TupleSpace;

  module.exports.Tuple = Tuple;

  module.exports.Client = Client;

  Linda = (function(_super) {
    __extends(Linda, _super);

    function Linda() {
      var _this = this;
      this.spaces = {};
      fs.readFile(path.resolve('lib', 'linda-socketio-client.js'), function(err, data) {
        if (err) {
          throw new Error("client js load error");
        }
        return _this.client_js_code = data;
      });
      setInterval(function() {
        var name, space, _ref, _results;
        _ref = _this.spaces;
        _results = [];
        for (name in _ref) {
          space = _ref[name];
          if (space != null) {
            _results.push(space.check_expire());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }, 60 * 3 * 1000);
    }

    Linda.prototype.tuplespace = function(name) {
      return this.spaces[name] || (this.spaces[name] = new TupleSpace(name));
    };

    Linda.prototype.listen = function(opts) {
      var _this = this;
      if (opts == null) {
        opts = {
          io: null,
          server: null
        };
      }
      if (opts.io == null) {
        throw new Error('"io" must be instance of Socket.IO');
      }
      if (!(opts.server instanceof http.Server)) {
        throw new Error('"server" must be instance of http.Server');
      }
      this.io = opts.io;
      this.server = opts.server;
      this.oldListeners = this.server.listeners('request').splice(0);
      this.server.removeAllListeners('request');
      this.server.on('request', function(req, res) {
        var listener, _i, _len, _ref, _results, _url;
        _url = url.parse(decodeURI(req.url), true);
        if (_url.pathname === "/linda/linda-socket.io.js") {
          res.writeHead(200);
          res.end(_this.client_js_code);
          return;
        }
        _ref = _this.oldListeners;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          listener = _ref[_i];
          _results.push(listener.call(_this.server, req, res));
        }
        return _results;
      });
      this.io.sockets.on('connection', function(socket) {
        var cids, watch_cids;
        cids = {};
        socket.on('__linda_write', function(data) {
          _this.tuplespace(data.tuplespace).write(data.tuple, data.options);
          return _this.emit('write', data);
        });
        socket.on('__linda_take', function(data) {
          var cid;
          cid = _this.tuplespace(data.tuplespace).take(data.tuple, function(err, tuple) {
            cid = null;
            return socket.emit("__linda_take_" + data.id, err, tuple);
          });
          cids[data.id] = cid;
          _this.emit('take', data);
          return socket.once('disconnect', function() {
            if (cid) {
              return _this.tuplespace(data.tuplespace).cancel(cid);
            }
          });
        });
        socket.on('__linda_read', function(data) {
          var cid;
          cid = _this.tuplespace(data.tuplespace).read(data.tuple, function(err, tuple) {
            cid = null;
            return socket.emit("__linda_read_" + data.id, err, tuple);
          });
          cids[data.id] = cid;
          _this.emit('read', data);
          return socket.once('disconnect', function() {
            if (cid) {
              return _this.tuplespace(data.tuplespace).cancel(cid);
            }
          });
        });
        watch_cids = {};
        socket.on('__linda_watch', function(data) {
          var cid;
          if (watch_cids[data.id]) {
            return;
          }
          watch_cids[data.id] = true;
          cid = _this.tuplespace(data.tuplespace).watch(data.tuple, function(err, tuple) {
            return socket.emit("__linda_watch_" + data.id, err, tuple);
          });
          cids[data.id] = cid;
          _this.emit('watch', data);
          return socket.once('disconnect', function() {
            if (cid) {
              return _this.tuplespace(data.tuplespace).cancel(cid);
            }
          });
        });
        return socket.on('__linda_cancel', function(data) {
          _this.tuplespace(data.tuplespace).cancel(cids[data.id]);
          return watch_cids[data.id] = false;
        });
      });
      return this;
    };

    return Linda;

  })(events.EventEmitter2);

  module.exports.Linda = new Linda;

}).call(this);
