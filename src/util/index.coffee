_ = require 'underscore'

class Util

  @clone: (object)->
    return JSON.parse(JSON.stringify(object)) if object?
    return object

  @trim: (str, char)->
    if str[0] is char
      str = str.substring 1
      str = Util.trim(str, char)

    length = str.length - 1
    if str[length] is char
      str = str.substring 0, length
      str = Util.trim(str, char)

    return str

  @obscureCredentials: (params, obscFields)->
    obscParams = {}
    _.each(params, (val, key)->
      if _.indexOf(obscFields, key) > -1
        obscParams[key] = '********'
      else
        obscParams[key] = val
    )

    return obscParams

  @convertArraysToObject: (array)->
    header = array[0]
    objects = []
    for i in [1...(array.length)]
      continue if _.isEmpty(_.compact(array[i]))
      obj = {}
      for j in [0...header.length]
        obj[header[j]] = array[i][j] if array[i][j]?
      objects.push obj
    return objects

  @transpose: (array)->
    transpdArr = []
    for i in [0...array.length]
      for j in [0...array[i].length]
        transpdArr[j] = [] unless transpdArr[j]?
        transpdArr[j][i] = array[i][j]
    return transpdArr

module.exports = Util