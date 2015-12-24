InternalStorageModel = require './index'

_ = require 'underscore'

class Rates extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'item_id': 'String'
        'rate': 'Number'
        'disabled': 'Boolean'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'rates'
      id: '_id'
    }
    return @schema

  isAddable: (itemId, rate, cb)->
    filters = {item_id: itemId}
    options = {sort: {created_dt: 'DESC'}}
    @getOne filters, options, (e, rates)=>
      return cb.apply @, [e] if e?

      return cb.apply @, [null, parseFloat(rates?['rate']) isnt parseFloat(rate)]

  validate: (params, rateId, cb)->
    errMsgs = []
    if _.isEmpty params['item_id']
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ITEM_ID

    unless params['rate']?
      errMsgs.push CONFIGURED_MESSAGES.REQUIRED_RATE
    else
      params['rate'] = parseFloat(params['rate'])
      if isNaN params['rate']
        errMsgs.push CONFIGURED_MESSAGES.INVALID_RATE

    if errMsgs.length > 0
      e = new Error CONFIGURED_MESSAGES.RATE_VALIDATION_FAILED
      e.errors = errMsgs
      return cb.apply @, [e]

    return  cb.apply @, []

  create: (params, cb)->
    @validate params, null, (e)=>
      return cb.apply @, [e] if e?

      @isAddable params['item_id'], params['rate'], (e, isAddable)=>
        return cb.apply @, [e] if e?

        return cb.apply @, [] unless isAddable

        super params, (e)=>
          return cb.apply @, [e]

  getByItemId: (itemId, cb)->
    filters = {item_id: itemId}
    options = {sort: {created_dt: 'DESC'}}

    @getByFilters filters, options, (e, items)=>
      return cb.apply @, [e, items]
  
  disable: (rateIds, cb)->
    rateIds = [rateIds] unless _.isArray rateIds
    filters = {_id: {$in: rateIds}}

    params = {'disabled': true}
    return @updateByFilters filters, params, cb

  enable: (rateIds, cb)->
    rateIds = [rateIds] unless _.isArray rateIds
    filters = {_id: {$in: rateIds}}

    params = {'disabled': false}
    return @updateByFilters filters, params, cb

module.exports = Rates