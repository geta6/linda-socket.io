process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
Linda = require(path.resolve())
TupleSpace = Linda.TupleSpace
Tuple = Linda.Tuple

createNewTupleSpace = ->
  return new TupleSpace("testspace_#{new Date()-1}")

describe 'instance of "TupleSpace"', ->

  ts = createNewTupleSpace()

  it 'should have "size" property', ->
    assert.equal ts.hasOwnProperty('size'), true

  describe '"size" property', ->

    it 'should return number of Tuples', ->
      assert.equal ts.size, 0

  it 'should have "write" method', ->
    assert.equal typeof ts['write'], 'function'

  describe '"write" method', ->

    it 'should store HashTuples', ->
      ts = createNewTupleSpace()
      assert.equal ts.size, 0
      ts.write {a:1, b:2}
      assert.equal ts.size, 1

    it 'should not store if not valid Tuple', ->
      ts = createNewTupleSpace()
      assert.equal ts.size, 0
      ts.write "foobar"
      ts.write [1,2]
      ts.write null
      assert.equal ts.size, 0
