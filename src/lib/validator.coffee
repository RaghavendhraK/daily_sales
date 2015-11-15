validator = require 'validator'

validator.extend = (name, fn)->
  validator[name] = ()->
    args = Array.prototype.slice.call(arguments)
    return fn.apply(validator, args)

validator.extend 'isPassword', (str)->
  re = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}/
  return re.test(str)

validator.extend 'isUsername', (str)->
  re = /^[A-Za-z][A-Za-z0-9_]*$/
  return re.test(str)

validator.extend 'isPhone', (str)->
  re = /^[+]{0,1}[0-9 \-\(\)]+$/
  return re.test(str)

validator.extend 'sanitize', (str)->
  str = validator.trim(str)
  str = validator.escape(str)
  return validator.toString(str)

validator.extend 'sanitizeParams', (params, schema)->
  for field, type of schema
    if params[field]?
    then paramValue = params[field]
    else paramValue = ''
    if (type is 'Array') and (paramValue instanceof Array)
      paramValue[key] = validator.sanitize(value) for key, value of paramValue
    else if type is 'Boolean'
      params[field] = validator.toBoolean(paramValue)
    else if type is 'Date'
      params[field] = validator.toDate(paramValue)
    else
      params[field] = validator.sanitize(paramValue)

  return params

module.exports = validator