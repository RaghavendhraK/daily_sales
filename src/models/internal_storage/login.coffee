UserModel = require './user'

Encrypt = require '../../lib/encrypt'
Token = require '../../lib/token'
validator = require '../../lib/validator'

class LoginModel extends UserModel

  login: (username, password, cb)->
    username = validator.sanitize(username).toLowerCase() if username?
    password = validator.sanitize(password) if password?

    fields = ['username']
    filters = {
      'username': username,
      'password': Encrypt.encrypt(password)
    }

    @getOne filters, fields, (ea, user)=>
      return cb(ea, null) if ea?

      #If users not found
      return cb(null, null) unless user?

      @deleteExistingAndCreateNewToken user, (et, authToken)->
        return cb(et, null) if et?

        cb(null, {
          user_details: user
          auth_token: authToken
        })

  logout: (authToken, cb)->
    authToken = validator.sanitize(authToken)

    Token.delete authToken, (e)->
      cb(e)

  deleteExistingAndCreateNewToken: (userDetails, cb)->
    @deleteExistingToken userDetails._id, (e)->
      return cb(e, null) if e
      
      Token.create userDetails, (e, authToken)->
        cb(e, authToken)

  deleteExistingToken: (userId, cb)->
    Token.clearUserTokens userId, (e)->
      return cb(e)

  isUserAuthenticated: (authToken, cb)->
    Token.getTokenDetails authToken, (eToken, userDetails)=>
      return cb.apply @, [eToken] if (eToken? or not(userDetails?))
      @getById userDetails['_id'], (eUser, user)=>
        return cb.apply @, [null, userDetails] if (user? and not(eUser?))
        Token.clearUserTokens userDetails['_id'], (eClearToken)=>
          return cb.apply @, [eClearToken]

module.exports = LoginModel