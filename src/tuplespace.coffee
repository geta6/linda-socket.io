Tuple = require __dirname+'/tuple'

module.exports = class TupleSpace
  constructor: (@name='noname')->
    @tuples = []
    @callbacks = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple)->
    return if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    called = []
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if c.tuple.match tuple
        called.push i
        ((c)->
          setImmediate -> c.callback(null, tuple)
        ).call(this, c)
        break if c.type == 'take'
    for i in [0...called.length]
      @callbacks.splice called[i]-i, 1
    @tuples.push tuple

  read: (tuple, callback)->
    callback = null unless typeof callback == 'function'
    if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
      setImmediate -> callback('argument_error') if callback
      return null
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      j = @tuples[i]
      if tuple.match j
        setImmediate -> callback(null, j) if callback
        return j
    if callback
      id = new Date-Math.random()
      @callbacks.push({type: 'read', callback: callback, tuple: tuple, id: id})
      return id
    return

  take: (tuple)->
    return null if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      j = @tuples[i]
      if tuple.match j
        @tuples.splice i, 1
        return j
    return null

  cancel: (id)->
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if id == c.id
        setImmediate -> c.callback('cancel', null)
        @callbacks.splice i, 1
        return
