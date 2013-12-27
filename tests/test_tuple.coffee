process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
LindaSocketIO = require path.resolve()

describe 'write tuple ["a", "b", "c"]', ->
  ts = new LindaSocketIO.TupleSpace
  it 'should be true', ->
    assert.equal ts.write(), true
