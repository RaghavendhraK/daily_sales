InternalStorageModel = require './index'

class ItemSales extends InternalStorageModel

  getSchema: ()->
    #Field names are in Dutch
    @schema = {
      fields: { #Fields with MSSQL Datatype
        'date' : 'Date'
        'shift' : 'String'
        'item_id': 'String'
        'item_name': 'String'
        'opening_stock': 'Number'
        'closing_stock': 'Number'
        'testing': 'Number'#TODO: find a better name for this
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