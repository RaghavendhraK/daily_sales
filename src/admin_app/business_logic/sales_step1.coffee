StaffModel = require '../../models/internal_storage/staffs'
DSModel = require '../../models/internal_storage/daily_sales'
CFModel = require '../../models/internal_storage/custom_fields'
DS_CONSTANTS = require '../../helpers/constant'

_ = require 'underscore'

class SalesStep1BL

  constructor: ()->
    @staffModel = new StaffModel
    @dsModel = new DSModel
    @cfModel = new CFModel

  getDailySales: (dsId, cb)=>
    return cb() unless dsId?

    @dsModel.getById dsId, (e, record)->
      return cb(e, record)

  getCashiers: (cb)->
    @staffModel.getCashiers (e, cashiers)->
      return cb.apply @, [e] if e?

      for cashier in cashiers
        cashier['_id'] = cashier['_id'].toString()

      return cb.apply @, [null, cashiers]

  getShifts: (cb)->
    shifts = []
    for shift in DS_CONSTANTS.SHIFTS
      shifts.push {
        key: shift
        value: shift
      }
    return cb.apply @, [null, shifts]

  save: (params, cb)->
    filters = {
      date: params['date']
      shift: params['shift']
    }
    @dsModel.getOne filters, (e, record)=>
      return cb.apply @, [e] if e?

      if record?
        @dsModel.upsert filters, params, (e)=>
          return cb.apply @, [e] if e?

          record = _.extend record, params
          return cb.apply @, [null, record]
      else
        @dsModel.create params, (e, dsRec)=>
          return cb.apply @, [e] if e?

          @cfModel.saveLastUpdatedDt params['date'], params['shift'], (e)=>
            return cb.apply @, [e, dsRec]

module.exports = SalesStep1BL