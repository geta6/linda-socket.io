module.exports = class Tuple

  @isHash: (data)->
    return false if !data or data instanceof Array or typeof data != "object"
    return true

  constructor: (@data)->

  match: (tuple)->
    return false unless Tuple.isHash(tuple)
    data = if tuple instanceof Tuple then tuple.data else tuple
    for k,v of @data
      if typeof v == 'object'
        return false if typeof data[k] != 'object'
        return false if JSON.stringify(v) != JSON.stringify(data[k])
      else
        return false if v != data[k]
    return true
