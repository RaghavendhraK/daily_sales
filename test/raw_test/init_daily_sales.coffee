global.config = require 'config'

DSModel = require '../../src/models/internal_storage/daily_sales'

dsModel = new DSModel

params = {
  'date': '1900-01-01'
  'shift' : 'N/A'
  'cashier': 'N/A'
  'cash': '0'
  'balance': '0'
  'remarks' : 'N/A'
}

dsModel.getOne {date: '1900-01-01'}, (e, dSales)->
  if e?
    console.log e
    process.exit(1)

  if dSales?
    console.log 'Daily Sales already initialized.'
    process.exit(0)

  dsModel.create params, (e)->
    if e?
      console.log e
      process.exit(1)
    else
      console.log 'Daily Sales initialized successfully.'
      process.exit(0)
