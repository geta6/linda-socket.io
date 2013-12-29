process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
assert.object_equal = (a,b)->
  @equal JSON.stringify(a), JSON.stringify(b)

async = require 'async'

Linda = require(path.resolve())
TupleSpace = Linda.TupleSpace
Tuple = Linda.Tuple


describe 'instance of "TupleSpace"', ->

  it 'should have "name" property', ->
    assert.equal new TupleSpace("foo").name, 'foo'

  it 'should have "callbacks" property', ->
    ts = new TupleSpace()
    assert.ok ts.hasOwnProperty('callbacks')
    assert.ok ts.callbacks instanceof Array

  it 'should have "size" property', ->
    assert.ok new TupleSpace().hasOwnProperty('size')

  describe '"size" property', ->

    it 'should return number of Tuples', ->
      assert.equal new TupleSpace().size, 0

  it 'should have "write" method', ->
    assert.equal typeof new TupleSpace()['write'], 'function'

  it 'should have "cancel" method', ->
    assert.equal typeof new TupleSpace()['cancel'], 'function'


  describe '"write" method', ->

    it 'should store HashTuples', ->
      ts = new TupleSpace("foo")
      assert.equal ts.size, 0
      ts.write {a:1, b:2}
      ts.write {a:1, b:3}
      assert.equal ts.size, 2

    it 'should not store if not valid Tuple', ->
      ts = new TupleSpace("foo")
      assert.equal ts.size, 0
      ts.write "foobar"
      ts.write [1,2]
      ts.write null
      assert.equal ts.size, 0


  it 'should have "read" method', ->
    assert.equal typeof new TupleSpace()['read'], 'function'

  describe '"read" method', ->
    ts = new TupleSpace("foo")
    ts.write {a:1, b:2, c:3}
    ts.write {a:1, b:2, d:88}
    ts.write {a:1, b:2, c:45}

    it 'should return matched Tuple', ->
      assert.object_equal ts.read(a:1, b:2).data, {a:1, b:2, c:45}
      assert.object_equal ts.read(a:1, b:2, c:3).data, {a:1, b:2, c:3}
      assert.object_equal ts.read(new Tuple(d:88)).data, {a:1, b:2, d:88}
      assert.object_equal ts.read({}).data, {a:1, b:2, c:45}

    it 'should return null if not matched', ->
      assert.equal ts.read({foo: 'bar'}), null

    it 'should return null if not valid Tuple', ->
      assert.equal ts.read("bar"), null
      assert.equal ts.read([1,2,3]), null
      assert.equal ts.read(null), null

    it 'should not delete matched Tuple', ->
      assert.equal ts.size, 3
      assert.notEqual ts.read({}), null
      assert.equal ts.size, 3


  it 'should have "take" method', ->
    assert.equal typeof new TupleSpace()['take'], 'function'

  describe '"take" method', ->
    ts = new TupleSpace
    ts.write {a:1, b:2, c:3}
    ts.write {a:1, b:2, d:88}
    ts.write {a:1, b:2, c:45}

    it 'should return null if not valid Tuple', ->
      assert.equal ts.take("bar"), null
      assert.equal ts.take([1,2,3]), null
      assert.equal ts.take(null), null

    it 'should return null if not matched', ->
      assert.equal ts.take({foo: 'bar'}), null

    it 'should return matched Tuple and delete', ->
      assert.object_equal ts.take({a:1, b:2, c:3}).data, {a:1, b:2, c:3}
      assert.equal ts.size, 2
      assert.equal ts.take({a:1, b:2, c:3}), null
      assert.object_equal ts.take(new Tuple({d:88})).data, {a:1, b:2, d:88}
      assert.equal ts.size, 1
      assert.object_equal ts.take({}).data, {a:1, b:2, c:45}
      assert.equal ts.size, 0
      assert.equal ts.take({}), null

  describe '"read" method with callback', ->

    it 'should return cancel_id', ->
      ts = new TupleSpace
      cid = ts.read {}, ->
      assert.ok cid > 0

    it 'should return matched Tuple', (done)->
      ts = new TupleSpace
      ts.write {a:1, b:2, c:3}
      ts.read {a:1, c:3}, (err, tuple)->
        assert.object_equal tuple.data, {a:1, b:2, c:3}
        done()

    it 'should wait if Tuple not found', (done)->
      ts = new TupleSpace
      async.parallel [
        (async_done)->
          ts.read {a:1, d:4}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2, c:3, d:4}
            async_done(null, tuple)
        (async_done)->
          ts.read {sensor: "light"}, (err, tuple)->
            assert.object_equal tuple.data, {sensor: "light", value: 80}
            async_done(null, tuple)
        (async_done)->
          ts.read {}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2, c:3}
            async_done(null, tuple)
      ], (err, results)->
        done()

      assert.equal ts.callbacks.length, 3
      ts.write {a:1, b:2, c:3}
      ts.write {a:1, b:2, c:3, d:4}
      ts.write {sensor: "light", value: 80}
      assert.equal ts.callbacks.length, 0

    it 'should not return Tuple if canceled', (done)->
      ts = new TupleSpace
      cid = null
      async.parallel [
        (async_done)->
          cid_ = ts.read {a:1}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2}
            async_done(null, cid_)
        (async_done)->
          cid = ts.read {}, (err, tuple)->
            assert.equal err, "cancel"
            async_done(null, cid)
      ], (err, callback_ids)->
        assert.notEqual callback_ids[0], callback_ids[1]
        done()

      assert.equal ts.callbacks.length, 2
      ts.cancel cid
      assert.equal ts.callbacks.length, 1
      ts.write {a:1, b:2}
      assert.equal ts.callbacks.length, 0

  describe '"take" method with callback', ->

    it 'should return cancel_id', ->
      ts = new TupleSpace
      cid = ts.take {}, ->
      assert.ok cid > 0

    it 'should return matched Tuple and delete', (done)->
      ts = new TupleSpace
      ts.write {a:1, b:2, c:3}
      ts.take {a:1, c:3}, (err, tuple)->
        assert.object_equal tuple.data, {a:1, b:2, c:3}
        assert.equal ts.size, 0
        done()

    it 'should wait if Tuple not found', (done)->
      ts = new TupleSpace
      async.parallel [
        (async_done)->
          ts.take {a:1, b:2}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2, c:3}
            async_done(null, tuple)
        (async_done)->
          ts.take {foo: "bar"}, (err, tuple)->
            assert.object_equal tuple.data, {foo: "bar"}
            async_done(null, tuple)
        (async_done)->
          ts.take {a:1, b:2}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2, c:300}
            async_done(null, tuple)
      ], (err, results)->
        assert.equal ts.callbacks.length, 0
        done()

      assert.equal ts.callbacks.length, 3
      ts.write {a:1, b:2, c:3}
      ts.write {foo: "bar"}
      ts.write {a:1, b:2, c:300}

    it 'should not return Tuple if cacneled', (done)->
      ts = new TupleSpace
      cid = null
      async.parallel [
        (async_done)->
          cid_ = ts.take {a:1}, (err, tuple)->
            assert.object_equal tuple.data, {a:1, b:2}
            async_done(null, cid_)
        (async_done)->
          cid = ts.take {}, (err, tuple)->
            assert.equal err, "cancel"
            async_done(null, cid)
      ], (err, callback_ids)->
        assert.notEqual callback_ids[0], callback_ids[1]
        done()

      assert.equal ts.callbacks.length, 2
      ts.cancel cid
      assert.equal ts.callbacks.length, 1
      ts.write {a:1, b:2}
      assert.equal ts.callbacks.length, 0

  describe '"watch" method', ->

    it 'should return cancel_id', ->
      ts = new TupleSpace
      cid = ts.watch {}, ->
      assert.ok cid > 0

    it 'should return Tuple when write(tuple)', (done)->
      ts = new TupleSpace

      results = []
      ts.watch {a:1, b:2}, (err, tuple)->
        results.push tuple.data
        if results.length == 2
          assert.deepEqual results,
                              [{a:1, b:2, c:3}, {a:1, b:2, name: "shokai"}]
          done()

      ts.write {a:1, b:2, c:3}
      ts.write {foo: "bar"}
      ts.write {a:1}
      ts.write {a:1, b:2, name: "shokai"}

    it 'should not return Tuple if canceled', (done)->
      ts = new TupleSpace
      cid = null
      async.parallel [
        (async_done)->
          cid_ = ts.watch {a:1}, (err, tuple)->
            assert.deepEqual tuple.data, {a:1, b:2}
            async_done(null, cid_)
        (async_done)->
          cid = ts.watch {}, (err, tuple)->
            assert.equal err, "cancel"
            async_done(null, cid)
      ], (err, callback_ids)->
        assert.notEqual callback_ids[0], callback_ids[1]
        done()

      assert.equal ts.callbacks.length, 2
      ts.cancel cid
      assert.equal ts.callbacks.length, 1
      ts.write {a:1, b:2}

