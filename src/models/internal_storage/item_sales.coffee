InternalStorageModel = require './index'

class ItemSales extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'item_id': 'String'
        'opening': 'Number'
        'add': 'Number'
        'closing': 'Number'
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

  getItemsByDailySalesId: (itemIds, dailySalesId, cb)->
    filters = {
      item_id: {$in: itemIds}
      daily_sales_id: dailySalesId
    }
    @getByFilters filters, (e, itemSales)=>
      return cb.apply @, [e, itemSales]

  save: (params, cb)->
    filters = {
      daily_sales_id: params['daily_sales_id']
      item_id: params['item_id']
    }
    @upsert filters, params, (e)=>
      return cb.apply @, [e]

module.exports = ItemSales