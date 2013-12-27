module.exports = class Tuple
  constructor: (@data)->

  data: ->
    return @data

  match: (tuple)->
    return false if tuple instanceof Array or typeof tuple != "object"
    data = if tuple instanceof Tuple then tuple.data else tuple
    for k,v of @data
      return false if v != data[k]
    return true
