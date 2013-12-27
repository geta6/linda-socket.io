module.exports = class Tuple
  constructor: (@data)->

  data: ->
    return @data

  match: (data)->
    for k,v of @data
      return false if v != data[k]
    return true
