ItemModel = require '../../models/internal_storage/items'
ISModel = require '../../models/internal_storage/item_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesSummaryBL

  constructor: ()->
    @dsModel = new DSModel

  getSummary: (dsId, cb)->
    dsRecord = {}
    @dsModel.getById dsId, (e, record)=>
      return cb.apply @, [e] if e?

      dsRecord = record
      dsRecord['total_sales'] = parseFloat(dsRecord['fuels']) + parseFloat(dsRecord['lubes']) + parseFloat(dsRecord['others'])
      dsRecord['balance'] = dsRecord['total_sales'] - parseFloat(dsRecord['expenses'])
      dsRecord['final_balance'] = dsRecord['balance'] + parseFloat(dsRecord['receipts'])

      if dsRecord['as_per_book']?
        dsRecord['result'] = (parseFloat(dsRecord['as_per_book']) - dsRecord['final_balance']).toFixed(2)
      
      return cb.apply @, [null, dsRecord]

  save: (params, cb)->
    dsId = params['dsId']

    tmpParams = {
      as_per_book: params['as_per_book'],
      remarks: params['remarks']
    }
    @dsModel.updateById dsId, tmpParams, (e)=>
      return cb.apply @, [e]

module.exports = SalesSummaryBL