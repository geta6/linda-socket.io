
Tuple = require __dirname+'/tuple'

module.exports = class TupleSpace
  constructor: (@name)->
    @tuples = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple)->
    return if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    @tuples.push tuple

  read: (tuple)->
