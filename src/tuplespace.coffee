
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
      j = @tuples[i]
      return j if tuple.match j
    return null

  take: (tuple)->
    return null if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      j = @tuples[i]
      if tuple.match j
        @tuples.splice i, 1
        return j
    return null

