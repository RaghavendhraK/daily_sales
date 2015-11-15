InternalStorageModel = require './index'

Encrypt = require '../../lib/encrypt'
Token = require '../../lib/token'

class User extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'username': 'String'
        'password': 'String'
        'email': 'String'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'users'
      id: '_id'
    } unless @schema?
    return @schema

  create: (params, cb)->
    params['password'] = Encrypt.encrypt(params['password'])
    super params, cb

  deleteById: (id, cb)->
    super id, (e)=>
      return cb.apply @, [e] if e?
      Token.clearUserTokens id, (e)=>
        return cb.apply @, [e]

  getByUsername: (username, cb)->
    filters = {'username': username}
    @getOne filters, cb

module.exports = User