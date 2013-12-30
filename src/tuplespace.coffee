Tuple = require __dirname+'/tuple'

module.exports = class TupleSpace
  constructor: (@name='noname')->
    @tuples = []
    @callbacks = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple, options={expire: Tuple.DEFAULT.expire})->
    return if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    tuple.expire = options.expire
    called = []
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if c.tuple.match tuple
        called.push i if c.type == 'take' or c.type == 'read'
        ((c)->
          setImmediate -> c.callback(null, tuple)
        ).call(this, c)
        break if c.type == 'take'
    for i in [0...called.length]
      @callbacks.splice called[i]-i, 1
    @tuples.push tuple

  create_callback_id: ->
    new Date()-Math.random()

  read: (tuple, callback)->
    callback = null unless typeof callback == 'function'
    if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
      if callback
        setImmediate -> callback('argument_error')
      return null
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      t = @tuples[i]
      if tuple.match t
        if callback
          setImmediate -> callback(null, t)
        return t
    if callback
      id = @create_callback_id()
      @callbacks.push {type: 'read', callback: callback, tuple: tuple, id: id}
      return id
    return

  take: (tuple, callback)->
    callback = null unless typeof callback == 'function'
    if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
      if callback
        setImmediate -> callback('argument_error')
      return null
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    for i in [@size-1..0]
      t = @tuples[i]
      if tuple.match t
        if callback
          setImmediate -> callback(null, t)
        @tuples.splice i, 1
        return t
    if callback
      id = @create_callback_id()
      @callbacks.push {type: 'take', callback: callback, tuple: tuple, id: id}
      return id
    return

  watch: (tuple, callback)->
    return unless typeof callback == 'function'
    if !Tuple.isHash(tuple) and !(tuple instance Tuple)
      setImmediate -> callback('argument_error')
      return
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    id = @create_callback_id()
    @callbacks.unshift {
      type: 'watch', callback: callback,
      tuple: tuple, id: id}
    return id

  cancel: (id)->
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if id == c.id
        setImmediate -> c.callback('cancel', null)
        @callbacks.splice i, 1
        return

  check_expire: ->
    expires = []
    for i in [0...@tuples.length]
      if @tuples[i].expire_at < new Date()/1000
        expires.push i
    for i in expires by -1
      @tuples.splice i, 1
    return expires.length
