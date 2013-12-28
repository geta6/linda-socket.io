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

  it 'should have "size" property', ->
    assert.ok new TupleSpace().hasOwnProperty('size')

  describe '"size" property', ->

    it 'should return number of Tuples', ->
      assert.equal new TupleSpace().size, 0

  it 'should have "write" method', ->
    assert.equal typeof new TupleSpace()['write'], 'function'


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
