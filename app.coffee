global.config = require 'config'

global.Log = require './src/util/log'

message = require __dirname + '/src/lib/messages'
message.configure(__dirname + '/messages')
global.CONFIGURED_MESSAGES = {}
message.load (e)->
  return cb(e) if e?
  global.CONFIGURED_MESSAGES = message

require './src/admin_app/app'