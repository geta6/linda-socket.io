(function() {
  var Linda, Tuple, TupleSpace, events, fs, http, socketio, url,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  http = require('http');

  url = require('url');

  fs = require('fs');

  events = require('events');

  socketio = require('socket.io');

  TupleSpace = module.exports.TupleSpace = require(__dirname + '/tuplespace');

  Tuple = module.exports.Tuple = require(__dirname + '/tuple');

  module.exports.Client = require(__dirname + '/linda-socketio-client');

  Linda = (function(_super) {
    __extends(Linda, _super);

    function Linda() {
      var _this = this;
      this.spaces = {};
      fs.readFile(__dirname + "/linda-socketio-client.js", function(err, data) {
        if (err) {
          throw new Error("client js load error");
        }
        return _this.client_js_code = data;
      });
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
      if (!(opts.io instanceof socketio.Manager)) {
        throw new Error('"io" must be instance of Socket.IO');
      }
      if (!(opts.server instanceof http.Server)) {
        throw new Error('"server" must be instance of http.Server');
      }
      this.io = opts.io;
      this.server = opts.server;
      this.server.on('request', function(req, res) {
        var _url;
        _url = url.parse(decodeURI(req.url), true);
        if (_url.pathname === "/linda/linda-socket.io.js") {
          res.writeHead(200);
          return res.end(_this.client_js_code);
        }
      });
      this.io.sockets.on('connection', function(socket) {
        var cids;
        cids = {};
        socket.on('__linda_write', function(data) {
          _this.tuplespace(data.tuplespace).write(data.tuple);
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
        socket.on('__linda_watch', function(data) {
          var cid;
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
          return _this.tuplespace(data.tuplespace).cancel(cids[data.id]);
        });
      });
      return this;
    };

    return Linda;

  })(events.EventEmitter);

  module.exports.Linda = new Linda;

}).call(this);
