process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
Tuple = require(path.resolve()).Tuple

describe 'tuple {"a": 1, "b": 2}', ->

  tuple = new Tuple(a:1, b:2)

  it 'should match {"a": 1, "b": 2}', ->
    assert.equal tuple.match({a:1, b:2}), true

  it 'should not match {"a": 1, "b": 3}', ->
    assert.equal tuple.match({a:1, b:3}), false

  it 'should match {"a": 1, "b": 2, "c": 3}', ->
    assert.equal tuple.match({a:1, b:2, c:3}), true
