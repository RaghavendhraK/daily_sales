InternalStorageModel = require './index'

class ItemSales extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'item_id': 'String'
        'opening_stock': 'Number'
        'closing_stock': 'Number'
        'testing': 'Number'
        'sales' : 'Number'
        'rate': 'Number'
        'amount': 'Number'
        'daily_sales_id': 'String'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table : 'item_sales'
      id: '_id'
    }
    return @schema

  getByDailySalesId: (dailySalesId, cb)->
    filters = {daily_sales_id: dailySalesId}
    @getByFilters filters, (e, itemSales)=>
      return cb.apply @, [e, itemSales]

  getByItemId: (itemId, from, to, cb)->
    filters = {
      item_id: itemId
      $and: [
        {date: {$gte: from}}
        {date: {$lte: to}}
      ]
    }
    @getByFilters filters, (e, itemSales)=>
      return cb.apply @, [e, itemSales]

  getOpeningStocks: (date, shift, cb)->
    

module.exports = ItemSales