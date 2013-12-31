## linda client for webbrowser

class LindaClient
  connect: (@io) ->
    return @

  tuplespace: (name) ->
    return new TupleSpace @io, name

class TupleSpace

  constructor: (@io, @name) ->
    @watch_cids = {}

  create_callback_id: ->
    return new Date()-Math.random()

  create_watch_callback_id: (tuple) ->
    key = JSON.stringify tuple
    return @watch_cids[key] || @watch_cids[key] = @create_callback_id()

  write: (tuple) ->
    @io.emit '__linda_write', {tuplespace: @name, tuple: tuple}

  take: (tuple, callback) ->
    id = @create_callback_id()
    @io.once "__linda_take_#{id}", (err, tuple) ->
      callback err, tuple
    @io.emit '__linda_take', {tuplespace: @name, tuple: tuple, id: id}
    return id

  read: (tuple, callback) ->
    id = @create_callback_id()
    @io.once "__linda_read_#{id}", (err, tuple) ->
      callback err, tuple
    @io.emit '__linda_read', {tuplespace: @name, tuple: tuple, id: id}
    return id

  watch: (tuple, callback) ->
    id = @create_watch_callback_id tuple
    @io.on "__linda_watch_#{id}", (err, tuple) ->
      callback err, tuple
    @io.emit '__linda_watch', {tuplespace: @name, tuple: tuple, id: id}
    return id

  cancel: (id) ->
    @io.emit '__linda_cancel', {tuplespace: @name, id: id}


if window?
  window.Linda = LindaClient
else if module? and module.exports?
  module.exports = LindaClient
