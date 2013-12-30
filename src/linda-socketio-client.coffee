## linda client for webbrowser

class Linda
  connect: (@io) ->

  tuplespace: (name) ->
    return new TupleSpace @io, name

class TupleSpace
  constructor: (@io, @name) ->

  write: (tuple) ->
    @io.emit '__linda_write', {tuplespace: @name, tuple: tuple}

window.linda = new Linda
