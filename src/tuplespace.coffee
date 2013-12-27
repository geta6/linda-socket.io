module.exports = class TupleSpace
  constructor: (@name)->
    @tuples = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple)->
    @tuples.push tuple
    return true
