ITCModel = require '../lib/model'
InternalStorage = require '../lib/adapters/internal_storage'

class InternalStorageModel extends ITCModel

  getDataAdapter: ()->
    unless @adapter?
      throw new Error CONFIGURED_MESSAGES.CONFIG_NOT_SET.INTERNAL_STORAGE unless (config.get('database')? and config.get('database').internal_storage?)

      @adapter = new InternalStorage(config.get('database').internal_storage)
      @adapter.setSchema(@getSchema())

    return @adapter

module.exports = InternalStorageModel