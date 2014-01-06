path = require 'path'
Tuple = require path.resolve 'lib', 'tuple'

module.exports = class TupleSpace
  constructor: (@name='noname') ->
    @tuples = []
    @callbacks = []
    @__defineGetter__ 'size', ->
      return @tuples.length

  write: (tuple, options={expire: Tuple.DEFAULT.expire}) ->
    return if !Tuple.isHash(tuple) and !(tuple instanceof Tuple)
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    tuple.expire =
      if typeof options.expire == 'number' and options.expire > 0
        options.expire
      else
        Tuple.DEFAULT.expire
    called = []
    taked = false
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if c.tuple.match tuple
        called.push i if c.type == 'take' or c.type == 'read'
        do (c) ->
          setImmediate -> c.callback(null, tuple)
        if c.type == 'take'
          taked = true
          break
    for i in called by -1
      @callbacks.splice i, 1
    @tuples.push tuple unless taked

  create_callback_id: ->
    return Date.now() - Math.random()

  read: (tuple, callback) ->
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

  take: (tuple, callback) ->
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

  watch: (tuple, callback) ->
    return unless typeof callback == 'function'
    if !Tuple.isHash(tuple) and !(tuple instance Tuple)
      setImmediate -> callback('argument_error')
      return
    tuple = new Tuple(tuple) unless tuple instanceof Tuple
    id = @create_callback_id()
    @callbacks.unshift
      id: id
      type: 'watch'
      tuple: tuple
      callback: callback
    return id

  cancel: (id) ->
    return unless id?
    for i in [0...@callbacks.length]
      c = @callbacks[i]
      if id == c.id
        setImmediate -> c.callback('cancel', null)
        @callbacks.splice i, 1
        return

  check_expire: ->
    expires = []
    for i in [0...@tuples.length]
      if @tuples[i].expire_at < Date.now() / 1000
        expires.push i
    for i in expires by -1
      @tuples.splice i, 1
    return expires.length
