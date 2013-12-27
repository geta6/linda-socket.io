(function() {
  var Linda, TupleSpace, fs, http, socketio, url;

  http = require('http');

  url = require('url');

  fs = require('fs');

  socketio = require('socket.io');

  module.exports.TupleSpace = require(__dirname + '/tuplespace');

  module.exports.Tuple = require(__dirname + '/tuple');

  Linda = (function() {
    var tuplespace, tuplespaces;

    function Linda() {
      var _this = this;
      fs.readFile(__dirname + "/linda-socketio-client.js", function(err, data) {
        if (err) {
          throw new Error("client js load error");
        }
        return _this.client_js_code = data;
      });
    }

    tuplespaces = {};

    tuplespace = function(name) {
      console.log("accessedd tuplespace - " + name);
      return tuplespaces[name] || (tuplespace[name] = new TupleSpace(name));
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
        if (_url.pathname === "/js/linda-socketio.js") {
          res.writeHead(200);
          return res.end(_this.client_js_code);
        }
      });
      return this.io.sockets.on('connection', function(socket) {
        return socket.on('__linda_write', function(data) {
          console.log("write tuple " + (JSON.stringify(data.tuple)));
          return tuplespace(data.tuplespace).write(data.tuple);
        });
      });
    };

    return Linda;

  })();

  TupleSpace = (function() {
    function TupleSpace(name) {
      this.name = name;
      this.tuples = [];
    }

    TupleSpace.prototype.write = function(tuple) {
      this.tuples << tuple;
      return console.log(tuple);
    };

    return TupleSpace;

  })();

  module.exports.Linda = new Linda;

}).call(this);
