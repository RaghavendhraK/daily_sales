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
      return cb.apply @, [null, dsRecord]

module.exports = SalesSummaryBL