InternalStorageModel = require './index'
RateModel = require './rates'

_ = require 'underscore'

class Items extends InternalStorageModel

  constructor: ()->
    @rateModel = new RateModel
    super()

  getSchema: ()->
    @schema = {
      fields: {
        'item_name': 'String'
        'item_type': 'String'
        'order': 'Number'
        'cost_price': 'Number'
        'selling_price': 'Number'
        'unit': 'String'
        'disabled': 'Boolean'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'items'
      id: '_id'
    }
    return @schema

  checkForDuplicate: (itemName, itemId, cb)->
    if _.isEmpty itemName
      return cb.apply @, [null, true]

    filters = {item_name: itemName}

    if itemId?
      itemId = @getDataAdapter()._getInstanceOfObjectId(itemId)
      filters['_id'] = {$ne: itemId}
    
    @count filters, (e, count)=>
      return cb.apply @, [e] if e?
      return cb.apply @, [null, (count > 0)]

  validate: (params, itemId, cb)->
    errMsgs = []
    if _.isEmpty params['item_name']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ITEM_NAME

    if _.isEmpty params['cost_price']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RATE
    else
      params['cost_price'] = parseFloat(params['cost_price']) 
      if isNaN params['cost_price']
        errMsgs.push CONFIGURED_MESSAGES.INVALID_RATE

    if _.isEmpty params['selling_price']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RATE
    else
      params['selling_price'] = parseFloat(params['selling_price']) 
      if isNaN params['selling_price']
        errMsgs.push CONFIGURED_MESSAGES.INVALID_RATE

    if _.isEmpty params['unit']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_UNIT

    @checkForDuplicate params['item_name'], itemId, (e, exists)=>
      return cb.apply @, [e] if e?

      if exists
        errMsgs.push CONFIGURED_MESSAGES.DUPLICATE_ITEM

      if errMsgs.length > 0
        e = new Error CONFIGURED_MESSAGES.ITEM_VALIDATION_FAILED
        e.errors = errMsgs
      else
        e = null
      
      return cb.apply @, [e]

  create: (params, cb)->
    @validate params, null, (e)=>
      return cb.apply @, [e] if e?

      super params, (e, savedItem)=>
        return cb.apply @, [e] if e?

        itemId = savedItem['_id'].toString()
        @createRates itemId, params, (e)=>
          return cb.apply @, [e, savedItem]

  updateById: (itemId, params, cb)->
    @validate params, itemId, (e)=>
      return cb.apply @, [e] if e?

      @createRates itemId, params, (e)=>
        return cb.apply @, [e] if e?

        super itemId, params, (e, savedItem)=>
          return cb.apply @, [e, savedItem]

  createRates: (itemId, params, cb)->
    rateParams = {
      'item_id': itemId
      'item_name': params['item_name']
      'rate': params['selling_price']
    }
    @rateModel.create rateParams, (e)=>
      return cb.apply @, [e]

  getActiveItems: (cb)->
    filters = {disabled: false}
    options = {sort: {order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getByItemIds: (itemIds, cb)->
    filters = {_id: {$in: itemIds}}
    options = {sort: {order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getAllItems: (cb)->
    filters = {}
    options = {sort: {order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

module.exports = Items