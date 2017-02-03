InternalStorageModel = require './index'
moment = require 'moment'

class CustomFields extends InternalStorageModel

  constructor: ()->
    super()

  getSchema: ()->
    @schema = {
      fields: {
        'last_updated_date': 'Date'
        'last_updated_shift': 'String'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table : 'custom_fields'
      id: '_id'
    }
    return @schema

  getLastUpdatedDt: (cb)->
    filters = {}
    @getOne filters, (e, rec)=>
      return cb.apply @, [e] if e?

      return cb.apply @, [null, {
        date: rec['last_updated_date']
        shift: rec['last_updated_shift']
      }]

  saveLastUpdatedDt: (date, shift, cb)->
    filters = {}
    @getOne filters, (e, rec)=>
      return cb.apply @, [e] if e?

      params = {last_updated_date: date, last_updated_shift: shift}
      if rec?
        @updateById rec['_id'], params, (e)=>
          return cb.apply @, [e]
      else
        @create params, (e)=>
          return cb.apply @, [e]

module.exports = CustomFields