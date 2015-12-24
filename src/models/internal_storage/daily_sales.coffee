InternalStorageModel = require './index'
ItemsModel = require './items'
ItemSalesModel = require './item_sales'

class DailySales extends InternalStorageModel

  constructor: ()->
    super()
    @itemsModel = new ItemsModel
    @itemSalesModel = new ItemSalesModel

  getSchema: ()->
    @schema = {
      fields: {
        'date' : 'Date'
        'shift' : 'String'
        'cashier': 'String'
        'cash': 'Number'
        'balance': 'Number'
        'remarks' : 'String'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table : 'daily_sales'
      id: '_id'
    }
    return @schema

  getByDate: (date, cb)->
    filters = {date: date}
    @getOne filters, (e, dailySale)=>
      return cb.apply @, [e] if e?

      getItemSales = (asyncCb)=>
        dailySaleID = dailySale['_id'].toString()
        @itemSalesModel.getByDailySalesId dailySaleID, (e, itemSales)->
          return asyncCb(e, itemSales)

      getItems = (itemSales, asyncCb)=>
        itemIds = _.pluck itemSales, 'item_id'
        @itemsModel.getByItemIds itemIds, (e, items)->
          return asyncCb(e) if e?

          orderedItemSales = []
          _.each items, (item)->
            itemSale = _.findWhere itemSales, {
              item_id: item['_id'].toString()
            }
            itemSale['item_name'] = item['item_name']
            orderedItemSales.push itemSale

          return asyncCb(null, orderedItemSales)

      tasks = [getItemSales, getItems]
      async.waterfall tasks, (e, itemSales)=>
        return cb.apply @, [e, itemSales]

module.exports = DailySales