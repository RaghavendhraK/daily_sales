Encrypt = require './encrypt'
fs = require 'fs-extra'
path = require 'path'

class Token
  @getTokenDir: ()->
    throw new Error CONFIGURED_MESSAGES.CONFIG_NOT_SET.TOKEN unless config.get('token_dir')?
    
    return config.get('token_dir')

  @create: (userDetails, cb)->
    tokenDir = @getTokenDir()
    encryptedDirName = Encrypt.encrypt(userDetails._id)
    encryptedFileName = Encrypt.encrypt(userDetails._id + new Date)
    filePath = "#{tokenDir}/#{encryptedDirName}/#{encryptedFileName}"

    fs.outputJson(filePath, userDetails, (e)->
      throw new Error "Token directory permission is not set" if e and (e.code is 'EACCES')
      throw e if e

      token = "#{encryptedDirName}|#{encryptedFileName}"
      cb(null, token)
    )

  @getUserTokenPath: (token, isFile)->
    return false unless token?

    tokenDir = @getTokenDir()
    splitToken = token.split('|')
    encryptedDirName = splitToken[0]
    
    userTokenPath = "#{tokenDir}/#{encryptedDirName}"

    userTokenPath += '/' + splitToken[1] if isFile

    #To make sure that the deleted files are under token directory
    userTokenPath = path.normalize(userTokenPath)
    if userTokenPath.indexOf(tokenDir) == 0
      return userTokenPath
    else
      return false

  @delete: (token, cb)->
    dirPath = @getUserTokenPath(token)
    return cb(new Error CONFIGURED_MESSAGES.INVALID_TOKEN) unless dirPath
    
    fs.remove(dirPath, (e)->
      return cb(e)
    )

  @getTokenDetails: (token, cb)->
    filePath = @getUserTokenPath(token, true)
    return cb(new Error CONFIGURED_MESSAGES.INVALID_TOKEN) unless filePath
    
    fs.readJson(filePath, (e, userDetails)->
      return cb(e, userDetails)
    )

  @isTokenExists: (userId, cb)->
    tokenDir = @getTokenDir()
    encryptedDirName = Encrypt.encrypt(userId)
    dirPath = "#{tokenDir}/#{encryptedDirName}"

    fs.exists(dirPath, (exists)->
      return cb(null, exists)
    )

  @clearUserTokens: (userId, cb)->
    tokenDir = @getTokenDir()
    encryptedDirName = Encrypt.encrypt(userId)
    dirPath = "#{tokenDir}/#{encryptedDirName}"

    fs.remove(dirPath, (e)->
      return cb(e)
    )

module.exports = Token