process.env.NODE_ENV = 'test'

path = require 'path'
assert = require 'assert'
Tuple = require(path.resolve()).Tuple

describe 'Tuple {"a": 1, "b": 2}', ->

  tuple = new Tuple(a:1, b:2)

  it 'should have "data" property', ->
    assert.equal tuple.hasOwnProperty('data'), true

  it 'should match {"a": 1, "b": 2}', ->
    assert.equal tuple.match({a:1, b:2}), true

  it 'should match {"a": 1, "b": 2, "c": 3}', ->
    assert.equal tuple.match({a:1, b:2, c:3}), true

  it 'should not match {"a": 1, "b": 3}', ->
    assert.equal tuple.match({a:1, b:3}), false

  it 'should not match {"a": 1}', ->
    assert.equal tuple.match({"a":1}), false

  it 'should not match [1,2,3]', ->
    assert.equal tuple.match([1,2,3]), false

  it 'should not match "foobar"', ->
    assert.equal tuple.match("foobar"), false
