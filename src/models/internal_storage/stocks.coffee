InternalStorageModel = require './index'

_ = require 'underscore'

class Stocks extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'item_id': 'String'
        'no_items': 'String'
        'receipt_no': 'String'
        'receipt_dt': 'Date'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'stocks'
      id: '_id'
    }
    return @schema

  checkForDuplicate: (receiptNo, itemId, stockId, cb)->
    if _.isEmpty(receiptNo) or _.isEmpty(itemId)
      return cb.apply @, [null, true]

    filters = {
      receipt_no: receiptNo
      item_id: itemId
    }

    if stockId?
      stockId = @getDataAdapter()._getInstanceOfObjectId(stockId)
      filters['_id'] = {$ne: stockId}
    
    @count filters, (e, count)=>
      return cb.apply @, [e] if e?
      return cb.apply @, [null, (count > 0)]

  validate: (params, stockId, cb)->
    errMsgs = []
    if _.isEmpty params['item_id']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ITEM_ID

    unless params['no_items']?
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_NO_ITEMS
    else
      params['no_items'] = parseFloat(params['no_items'])
      if isNaN params['no_items']
        errMsgs.push CONFIGURED_MESSAGES.INVALID_NO_ITEMS

    if _.isEmpty params['receipt_no']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RECEIPT_NO

    if _.isEmpty params['receipt_dt']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RECEIPT_DATE

    @checkForDuplicate params['receipt_no'], params['item_id'], stockId, (e, exists)=>
      return cb.apply @, [e] if e?

      if exists
        errMsgs.push CONFIGURED_MESSAGES.DUPLICATE_STOCK

      if errMsgs.length > 0
        e = new Error CONFIGURED_MESSAGES.STOCK_VALIDATION_FAILED
        e.errors = errMsgs
      else
        e = null
      
      return cb.apply @, [e]

  create: (params, cb)->
    @validate params, null, (e)=>
      return cb.apply @, [e] if e?

      super params, (e, savedStock)=>
        return cb.apply @, [e, savedStock]

  updateById: (stockId, params, cb)->
    @validate params, stockId, (e)=>
      return cb.apply @, [e] if e?

      super stockId, params, (e, savedStock)=>
        return cb.apply @, [e, savedStock]

  getAllStocks: (cb)->
    filters = {}
    options = {sort: {receipt_dt: 'DESC'}}
    @getByFilters filters, options, (e, stocks)=>
      return cb.apply @, [e, stocks]

module.exports = Stocks