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
        'fuels': 'Number'
        'lubes': 'Number'
        'others': 'Number'
        'expenses': 'Number'
        'receipts': 'Number'
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

  _getItems: (dsRec, cb)->
    getItemSales = (asyncCb)=>
      dailySaleID = dsRec['_id'].toString()
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

  #Check why required
  getByDate: (date, cb)->
    filters = {date: date}
    options = {sort: {shift: 'DESC'}}

    @getOne filters, options, (e, dsRec)=>
      return cb.apply @, [e] if e?

      @_getItems dsRec, (e, items)=>
        return cb.apply @, [e, items]

  getRecent: (date, cb)->
    filters = {date: {$lte: date}}
    options = {sort: {
      date: 'DESC',
      shift: 'DESC'
    }}
    @getOne filters, options, (e, dsRec)=>
      return cb.apply @, [e] if e?

      @_getItems dsRec, (e, items)=>
        return cb.apply @, [e, items]

  getPrevious: (date, shift, cb)->
    filters = {
      $and: [
        { date: { $lte: date } }
        {
          $or: [
            { date: { $ne: date } }
            { shift: { $ne: shift } }
          ]
        }
      ]
    }
    options = {
      sort: {
        date: 'DESC',
        shift: 'DESC'
      }
    }
    @getOne filters, options, (e, dsRec)=>
      return cb.apply @, [e, dsRec]

module.exports = DailySales