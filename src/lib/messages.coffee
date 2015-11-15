fs = require 'fs-extra'
_ = require 'underscore'
async = require 'async'

class Message

  configure: (msgDir)->
    @msgDir = msgDir

  load: (cb)->
    files = []
    try
      files = fs.readdirSync(@msgDir)
    catch e
      return cb(new Error "'#{@msgDir}' does not exist")
    
    loadMessagesFromFile = (file, parallelLoopCb)=>
      filePath = "#{@msgDir}/#{file}"
      fs.readJson filePath, (e, content)=>
        return parallelLoopCb(throw new Error "#{filePath} Error: #{e.message}") if e?
        _.extend(@, content)
        parallelLoopCb()

    async.each files, loadMessagesFromFile, (e)->
      cb(e)

message = new Message
module.exports = message