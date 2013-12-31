Linda Socket.IO
===============
<a href="http://en.wikipedia.org/wiki/Linda_(coordination_language)">Coordinatioin Launguage "Linda"</a> implementation for Node.js and Socket.IO

- https://github.com/shokai/linda-socket.io

[![Travis CI Status Badge](https://travis-ci.org/shokai/linda-socket.io.png)](https://travis-ci.org/shokai/linda-socket.io)


Install
-------

    % npm install linda-socket.io


Requirements
------------
- Node.js
- [Socket.IO](http://socket.io/)


Linda
-----
Linda is a coordination launguage for parallel programming.

* http://en.wikipedia.org/wiki/Linda_(coordination_language)
* http://ja.wikipedia.org/wiki/Linda


### TupleSpace
Shared memory on Sinatra.


### Tuple Operations
- write( tuple )
  - put a Tuple into the TupleSpace
- take( tuple, callback(tuple) )
  - get a matched Tuple from the TupleSpace and delete
- read( tuple, callback(tuple) )
  - get a matched Tuple from the TupleSpace
- watch( tuple, callback(tuple) )
  - overwatch written Tuples in the TupleSpace


Samples
-------

    % git clone https://github.com/shokai/linda-socket.io.git
    % cd linda-socket.io
    % npm install
    % npm install -g grunt-cli
    % npm install -g coffee-script


### Chat

    % coffee samples/chat/server.coffee 3000

=> http://localhost:3000


### Job-Queue

    % coffee samples/job-queue/server.coffee 3000

=> http://localhost:3000


Usage
-----

### Setup

Server Side (node.js)

```javascript
var http = require('http');

var app_handler = function(req, res){
  // your web app code
};

var app = http.createServer(app_handler);

var io = require('socket.io').listen(app);

var linda = require('linda-socket.io').Linda.listen({io: io, server: app});

app.listen(3000);
console.log("server start - http://localhost:3000");
```


Client Side (web browser)

```html
<script src="/socket.io/socket.io.js"></script>
<script src="/linda/linda-socket.io.js"></script>
```

```javascript
var socket = io.connect("http://localhost:3000");
var linda = new Linda().connect(socket);
```

Client Side (node.js)

```javascript
var LindaClient = require('linda-socket.io').Client;
var socket = require('socket.io-client').connect('http://localhost:3000');
var linda = new LindaClient().connect(socket);
```


### Job-Queue Sample

job client

```javascript
// connect to tuplespace (shared memory)
var ts = linda.tuplespace("calc");

// request
$("#btn_request").click(function(){
  ts.write({type: "request", query: "1-2+3*4"});
});

// wait result
socket.on('connect', function(){
  // overwatch Tuple
  ts.watch({type: 'result'}, function(err, tuple){
    console.log(tuple.data.result); // => "1-2+3*4 = 11"
  });
});
```


job worker
```javascript
// connect to tuplespace (shared memory)
var ts = linda.tuplespace("calc");

// calculate
var work = function(){
  ts.take({type: 'request'}, function(err, tuple){
    var result = eval(tuple.data.query); // => "1-2+3*4"
    console.log(tuple.data.query+" = "+result); // => "1-2+3*4 = 11"
    ts.write({type: 'result', result: result}); // return to 'client' side
    work(); // recursive call
  });
};

socket.on('connect', function(){ // Socket.IO's "connect" event
  work();
});
```

see [samples](https://github.com/shokai/linda-socket.io/tree/master/samples)

Test
----

    % npm install -g grunt-cli
    % grunt test

watch

    % grunt



Contributing
------------
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
