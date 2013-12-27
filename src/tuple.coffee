module.exports = class Tuple
  constructor: (@data)->

  data: ->
    return @data

  match: (tuple)->
    return false if tuple instanceof Array or typeof tuple != "object"
    for k,v of @data
      return false if v != tuple[k]
    return true
