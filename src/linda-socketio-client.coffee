class Linda
  connect: (@io) ->

  tuplespace: (name) ->
    new TupleSpace @io, name

class TupleSpace
  constructor: (@io, @name) ->

  write: (tuple) ->
    @io.emit '__linda_write', {tuplespace: @name, tuple: tuple}

linda = new Linda
