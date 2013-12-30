## linda client for webbrowser

class Linda
  connect: (@io) ->

  tuplespace: (name) ->
    return new TupleSpace @io, name

class TupleSpace

  constructor: (@io, @name) ->

  create_callback_id: ->
    return new Date()-Math.random()

  write: (tuple) ->
    @io.emit '__linda_write', {tuplespace: @name, tuple: tuple}

  take: (tuple, callback) ->
    id = @create_callback_id()
    @io.once "__linda_take_#{id}", (tuple) ->
      callback null, tuple
    @io.emit '__linda_take', {tuplespace: @name, tuple: tuple, id: id}

  read: (tuple, callback) ->
    id = @create_callback_id()
    @io.once "__linda_read_#{id}", (tuple) ->
      callback null, tuple
    @io.emit '__linda_read', {tuplespace: @name, tuple: tuple, id: id}

  watch: (tuple, callback) ->
    id = @create_callback_id()
    @io.on "__linda_watch_#{id}", (tuple) ->
      callback null, tuple
    @io.emit '__linda_watch', {tuplespace: @name, tuple: tuple, id: id}

if window
  window.linda = new Linda
else if module and module.exports
  module.exports = Linda
