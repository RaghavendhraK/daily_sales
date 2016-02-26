InternalStorageModel = require './index'

_ = require 'underscore'

class Staffs extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'staff_name': 'String'
        'staff_type': 'String'
        'referrer': 'String'
        'phone': 'String'
        'address': 'String'
        'doj': 'Date'
        'disabled': 'Boolean'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table: 'staffs'
      id: '_id'
    }
    return @schema

  isDuplicate: (staffName, staffId, cb)->
    if _.isEmpty staffName
      return cb.apply @, [null, false]

    filters = {staff_name: staffName}

    if staffId?
      staffId = @getDataAdapter()._getInstanceOfObjectId(staffId)
      filters['_id'] = {$ne: staffId}
    
    @count filters, (e, count)=>
      return cb.apply @, [e] if e?
      return cb.apply @, [null, (count > 0)]

  validate: (params, staffId, cb)->
    errMsgs = []
    @isDuplicate params['staff_name'], staffId, (e, exists)=>
      return cb.apply @, [e] if e?

      if exists
        errMsgs.push CONFIGURED_MESSAGES.DUPLICATE_STAFF
      else if _.isEmpty params['staff_name']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_STAFF_NAME

      if _.isEmpty params['staff_type']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_STAFF_TYPE

      if _.isEmpty params['phone']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_PHONE

      if _.isEmpty params['address']
        errMsgs.push CONFIGURED_MESSAGES.REQUIRED_ADDRESS

      if errMsgs.length > 0
        e = new Error CONFIGURED_MESSAGES.STAFF_VALIDATION_FAILED
        e.errors = errMsgs
      else
        e = null
      
      return cb.apply @, [e]

  create: (params, cb)->
    @validate params, null, (e)=>
      return cb.apply @, [e] if e?

      super params, (e, savedStaff)=>
        return cb.apply @, [e, savedStaff]

  updateById: (staffId, params, cb)->
    @validate params, staffId, (e)=>
      return cb.apply @, [e] if e?

      super staffId, params, (e, savedStaff)=>
        return cb.apply @, [e, savedStaff]

  getActiveStaffs: (cb)->
    filters = {disabled: false}
    options = {sort: {staff_name: 'ASC'}}
    @getByFilters filters, options, (e, staffs)=>
      return cb.apply @, [e, staffs]

  getAllStaffs: (cb)->
    filters = {}
    options = {sort: {staff_name: 'ASC'}}
    @getByFilters filters, options, (e, staffs)=>
      return cb.apply @, [e, staffs]

  getCashiers: (cb)->
    filters = {
      staff_type: 'cashier'
    }
    options = {sort: {staff_name: 'ASC'}}
    @getByFilters filters, options, (e, staffs)=>
      return cb.apply @, [e, staffs]

module.exports = Staffs