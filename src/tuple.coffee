module.exports = class Tuple

  @isHash: (data)->
    return false if !data or data instanceof Array or typeof data != "object"
    return true

  constructor: (@data)->

  match: (tuple)->
    return false unless Tuple.isHash(tuple)
    data = if tuple instanceof Tuple then tuple.data else tuple
    for k,v of @data
      return false if v != data[k]
    return true
