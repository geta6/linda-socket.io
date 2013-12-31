process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
async = require 'async'
LindaClient = require(path.resolve()).Client
TestServer = require './server'

port = process.env.PORT-0 || 13000

## start server
server = new TestServer().listen(port)
setTimeout ->
  server.close()
, 3000

## client
create_client = ->
  socket = require('socket.io-client').connect("http://localhost:#{port}")
  return new LindaClient().connect(socket)


describe 'instance of LindaClient', ->

  it 'should have method "connect"', ->
    assert.equal typeof new LindaClient()['connect'], 'function'

  it 'should have property "io"', ->
    assert.ok create_client().hasOwnProperty('io')

  it 'should have connecttion', (done) ->
    linda = create_client()
    ts = linda.tuplespace('chat')

    linda.io.on 'connect', ->
      assert.ok
      done()

  it 'should have method "tuplespace"', ->
    assert.equal typeof new LindaClient()['tuplespace'], 'function'


  describe 'method "tuplespace"', ->

    it 'should have property "name"', ->
      ts = create_client().tuplespace('test')
      assert.equal ts.name, 'test'

    it 'should have method "create_callback_id"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['create_callback_id'], 'function'

    it 'should have method "write"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['write'], 'function'

    it 'should have method "read"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['read'], 'function'

    it 'should have method "take"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['take'], 'function'

    it 'should have method "watch"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['write'], 'function'

    it 'should have method "cancel"', ->
      ts = create_client().tuplespace('test')
      assert.equal typeof ts['cancel'], 'function'

    describe 'method "write"', ->

      it 'should write Tuple', (done) ->
        linda = create_client()
        ts = linda.tuplespace('write')

        msg = "hello world #{new Date()}"

        assert.equal server.linda.tuplespace('write').size, 0
        linda.tuplespace('write').write {type: "chat", message: msg}
        server.linda.tuplespace('write').read {type: "chat"}, (err, tuple) ->
          assert.deepEqual tuple.data, {type: "chat", message: msg}
          assert.equal server.linda.tuplespace('write').size, 1
          done()


    describe 'method "watch"', ->

      it 'should return cancel_id', ->
        cid = create_client().tuplespace('watch_cancel').watch {}, ->
        assert.ok cid > 0

      it 'should return matched Tuple', (done) ->
        writer = create_client()
        watcher = create_client()
        val_a = Math.random()
        val_b = Math.random()

        count = 0
        watcher.tuplespace('watch').watch {sensor: "light"}, (err, tuple) ->
          count += 1
          switch count
            when 1
              assert.deepEqual tuple.data, {sensor: "light", value: val_a}
            when 2
              assert.deepEqual tuple.data, {sensor: "light", value: val_b}
              done()

        writer.tuplespace('watch').write {sensor: "foo", value: 20}
        writer.tuplespace('watch').write {sensor: "light", value: val_a}
        writer.tuplespace('watch').write {name: "shokai", age: 29}
        writer.tuplespace('watch').write {sensor: "light", value: val_b}


      it 'should not return Tuple if canceled', (done) ->
        linda = create_client()
        ts = linda.tuplespace('watch_cancel_test')
        cid = null
        async.parallel [
          (async_done) ->
            cid_ = ts.watch {a:1}, (err, tuple) ->
              assert.deepEqual tuple.data, {a:1, b:2}
              async_done(null, cid_)
          (async_done) ->
            cid = ts.watch {}, (err, tuple) ->
              assert.equal err, "cancel"
              async_done(null, cid)
        ], (err, callback_ids) ->
          assert.notEqual callback_ids[0], callback_ids[1]
          assert.equal server_ts.callbacks.length, 1
          done()

        server_ts = server.linda.tuplespace('watch_cancel_test')
        assert.equal server_ts.callbacks.length, 0
        ts.cancel cid
        ts.write {a:1, b:2}


    describe 'method "read"', ->

      it 'should return cancel_id', ->
        cid = create_client().tuplespace('read_cancel').read {}, ->
        assert.ok cid > 0

      it 'should return matched Tuple', (done) ->
        reader = create_client()
        writer = create_client()

        msg = "hello world #{new Date}"
        writer.tuplespace('read').write {type: "chat", message: msg}
        async.parallel [
          (async_done) ->
            reader.tuplespace('read').read {type: "chat"}, (err, tuple) ->
              assert.deepEqual tuple.data, {type: "chat", message: msg}
              async_done()
          (async_done) ->
            reader.tuplespace('read').read {type: "foobar"}, (err, tuple) ->
              assert.ok false
              async_done()
            setTimeout ->
              assert.ok
              async_done()
            , 500
        ], (err, results) ->
          assert.equal server.linda.tuplespace('read').size, 1
          assert.equal server.linda.tuplespace('read').callbacks.length, 1
          done()


      it 'should wait if Tuple not found', (done) ->
        reader = create_client()
        writer = create_client()

        msg = "hello world #{new Date}"
        reader.tuplespace('read_callback').read {type: "chat"}, (err, tuple) ->
          assert.deepEqual tuple.data, {type: "chat", message: msg}
          done()

        writer.tuplespace('read_callback').write {type: "chat", message: msg}

      it 'should not return Tuple if canceled', (done) ->
        linda = create_client()
        ts = linda.tuplespace('read_cancel_test')
        cid = null
        async.parallel [
          (async_done) ->
            cid_ = ts.read {a:1}, (err, tuple) ->
              assert.deepEqual tuple.data, {a:1, b:2}
              async_done(null, cid_)
          (async_done) ->
            cid = ts.read {}, (err, tuple) ->
              assert.equal err, "cancel"
              async_done(null, cid)
        ], (err, callback_ids) ->
          assert.notEqual callback_ids[0], callback_ids[1]
          assert.equal server_ts.callbacks.length, 0
          done()

        server_ts = server.linda.tuplespace('read_cancel_test')
        assert.equal server_ts.callbacks.length, 0
        ts.cancel cid
        ts.write {a:1, b:2}


    describe 'method "take"', ->

      it 'should return cancel_id', ->
        cid = create_client().tuplespace('take_cancel').take {}, ->
        assert.ok cid > 0

      it 'should return matched Tuple and delete', (done) ->
        taker = create_client()
        writer = create_client()

        msg = "hello world #{new Date}"
        writer.tuplespace('take').write {type: "chat", message: msg}
        async.parallel [
          (async_done) ->
            taker.tuplespace('take').take {type: "chat"}, (err, tuple) ->
              assert.deepEqual tuple.data, {type: "chat", message: msg}
              async_done()
          (async_done) ->
            taker.tuplespace('take').take {type: "foobar"}, (err, tuple) ->
              assert.ok false
              async_done()
            setTimeout ->
              assert.ok
              async_done()
            , 500
        ], (err, results) ->
          assert.equal server.linda.tuplespace('take').size, 0
          assert.equal server.linda.tuplespace('take').callbacks.length, 1
          done()


      it 'should wait if Tuple not found', (done) ->
        taker = create_client()
        writer = create_client()

        msg = "hello world #{new Date}"
        taker.tuplespace('take_callback').read {type: "chat"}, (err, tuple) ->
          assert.deepEqual tuple.data, {type: "chat", message: msg}
          done()

        writer.tuplespace('take_callback').write {type: "chat", message: msg}

      it 'should not return Tuple if canceled', (done) ->
        linda = create_client()
        ts = linda.tuplespace('take_cancel_test')
        cid = null
        async.parallel [
          (async_done) ->
            cid_ = ts.take {a:1}, (err, tuple) ->
              assert.deepEqual tuple.data, {a:1, b:2}
              async_done(null, cid_)
          (async_done) ->
            cid = ts.take {}, (err, tuple) ->
              assert.equal err, "cancel"
              async_done(null, cid)
        ], (err, callback_ids) ->
          assert.notEqual callback_ids[0], callback_ids[1]
          assert.equal server_ts.callbacks.length, 0
          done()

        server_ts = server.linda.tuplespace('take_cancel_test')
        assert.equal server_ts.callbacks.length, 0
        ts.cancel cid
        ts.write {a:1, b:2}

