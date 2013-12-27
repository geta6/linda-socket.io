
Tuple = require __dirname+'/tuple'

module.exports = class TupleSpace
  constructor: (@name="noname")->
    @tuples = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple)->
    return if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    @tuples.push tuple

  read: (tuple)->
    return null if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      return @tuples[i] if tuple.match @tuples[i]
    return null
