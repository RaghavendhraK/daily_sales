DSModel = require '../../models/internal_storage/daily_sales'

moment = require 'moment'
_ = require 'underscore'

class SalesListBL

  constructor: ()->
    @dsModel = new DSModel

  getSales: (params, cb)->
    fromDate = params['from_date']
    toDate = params['to_date']

    unless fromDate?
      fromDate = moment().subtract(15, 'd').format('YYYY-MM-DD')
      toDate = moment().format('YYYY-MM-DD')

    filters = {
      $and: [{
        date: { $gte: fromDate }
      }, {
        date: { $lte: toDate }
      }]
    }
    options = {
      sort: {
        date: 'DESC',
        shift: 'DESC'
      }
    }
    @dsModel.getByFilters filters, options, (e, records)=>
      return cb.apply @, [e] if e?

      for tmp in records
        tmp['total_sales'] = parseFloat(tmp['fuels']) + parseFloat(tmp['lubes']) + parseFloat(tmp['others'])
        tmp['balance'] = tmp['total_sales'] + parseFloat(tmp['receipts']) - parseFloat(tmp['expenses'])
        tmp['date'] = moment(tmp['date'], 'YYYY-MM-DD').format('DD/MM/YYYY')
        
      return cb.apply @, [null, records]

module.exports = SalesListBL