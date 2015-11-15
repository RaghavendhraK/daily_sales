crypto = require 'crypto'

class Encrypt
  @encrypt: (string)->
    throw Error 'Invalid input' unless string?

    throw Error 'Salt is not configured' unless config.get('salt')?

    encryptedString = crypto.createHash('sha256')
      .update(string + config.get('salt'))
      .digest('hex')
    return encryptedString

module.exports = Encrypt