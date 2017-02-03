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
        'display_order': 'Number'
        'rate': 'Number'
        'unit': 'String'
        'disabled': 'Boolean'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'items'
      id: '_id'
    }
    return @schema

  isDuplicate: (itemName, itemId, cb)->
    return cb.apply @, [null, false] if _.isEmpty itemName

    filters = {item_name: itemName}

    if itemId?
      itemId = @getDataAdapter()._getInstanceOfObjectId(itemId)
      filters['_id'] = {$ne: itemId}
    
    @count filters, (e, count)=>
      return cb.apply @, [e] if e?
      return cb.apply @, [null, (count > 0)]

  validate: (params, itemId, cb)->
    errMsgs = []
    @isDuplicate params['item_name'], itemId, (e, duplicate)=>
      return cb.apply @, [e] if e?

      if duplicate
        errMsgs.push CONFIGURED_MESSAGES.DUPLICATE_ITEM
      else if _.isEmpty params['item_name']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ITEM_NAME

      if _.isEmpty params['rate']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RATE
      else
        params['rate'] = parseFloat(params['rate'])
        if isNaN params['rate']
          errMsgs.push CONFIGURED_MESSAGES.INVALID_RATE

      if _.isEmpty params['unit']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_UNIT
      else
        unless isNaN parseFloat(params['unit'])
          errMsgs.push CONFIGURED_MESSAGES.INVALID_UNIT

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
      'rate': params['rate']
    }
    @rateModel.create rateParams, (e)=>
      return cb.apply @, [e]

  getActiveItems: (cb)->
    filters = {disabled: false}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getByItemIds: (itemIds, cb)->
    filters = {_id: {$in: itemIds}}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getAllItems: (cb)->
    filters = {}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getFuels: (cb)->
    filters = {item_type: 'fuel'}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getLubes: (cb)->
    filters = {item_type: 'lubes'}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

  getOthers: (cb)->
    filters = {item_type: 'others'}
    options = {sort: {item_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]

module.exports = Items