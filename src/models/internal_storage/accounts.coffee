InternalStorageModel = require './index'

_ = require 'underscore'

class Accounts extends InternalStorageModel

  constructor: ()->
    super()

  getSchema: ()->
    @schema = {
      fields: {
        'account_name': 'String'
        'account_type': 'String'
        'display_order': 'Number'
        'disabled': 'Boolean'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'accounts'
      id: '_id'
    }
    return @schema

  isDuplicate: (accountName, accountId, cb)->
    return cb.apply @, [null, false] if _.isEmpty accountName

    filters = {account_name: accountName}

    if accountId?
      accountId = @getDataAdapter()._getInstanceOfObjectId(accountId)
      filters['_id'] = {$ne: accountId}
    
    @count filters, (e, count)=>
      return cb.apply @, [e] if e?
      return cb.apply @, [null, (count > 0)]

  validate: (params, accountId, cb)->
    errMsgs = []
    @isDuplicate params['account_name'], accountId, (e, duplicate)=>
      return cb.apply @, [e] if e?

      if duplicate
        errMsgs.push CONFIGURED_MESSAGES.DUPLICATE_ACCOUNT
      else if _.isEmpty params['account_name']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ACCOUNT_NAME

      if errMsgs.length > 0
        e = new Error CONFIGURED_MESSAGES.ACCOUNT_VALIDATION_FAILED
        e.errors = errMsgs
      else
        e = null
      
      return cb.apply @, [e]

  create: (params, cb)->
    @validate params, null, (e)=>
      return cb.apply @, [e] if e?

      super params, (e, savedAccount)=>
        return cb.apply @, [e, savedAccount]

  updateById: (accountId, params, cb)->
    @validate params, accountId, (e)=>
      return cb.apply @, [e] if e?

      super accountId, params, (e, savedAccount)=>
        return cb.apply @, [e, savedAccount]

  getActiveAccounts: (cb)->
    filters = {disabled: false}
    options = {sort: {account_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, accounts)=>
      return cb.apply @, [e, accounts]

  getByAccountIds: (accountIds, cb)->
    filters = {_id: {$in: accountIds}}
    options = {sort: {account_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, accounts)=>
      return cb.apply @, [e, accounts]

  getAllAccounts: (cb)->
    filters = {}
    options = {sort: {account_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, accounts)=>
      return cb.apply @, [e, accounts]

  getExpenses: (cb)->
    filters = {account_type: 'expenses'}
    options = {sort: {account_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, accounts)=>
      return cb.apply @, [e, accounts]

  getReceipts: (cb)->
    filters = {account_type: 'receipts'}
    options = {sort: {account_type: 'ASC', display_order: 'ASC'}}
    @getByFilters filters, options, (e, accounts)=>
      return cb.apply @, [e, accounts]

module.exports = Accounts