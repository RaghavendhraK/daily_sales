ItemModel = require '../../models/internal_storage/items'
ISModel = require '../../models/internal_storage/item_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesOthersBL

  constructor: ()->
    @itemModel = new ItemModel
    @isModel = new ISModel
    @dsModel = new DSModel

  getOtherItems: (dsId, cb)->
    others = []
    _getOtherItems = (asyncCb)=>
      @itemModel.getOthers (e, records)->
        return asyncCb(e) if e?
        others = records
        return asyncCb()
    
    dsRecord = {}
    _getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e) if e?
        dsRecord = record
        return asyncCb()

    saleItems = []
    _getOtherItemSales = (asyncCb)=>
      itemIds = []
      for temp in others
        itemIds.push temp['_id'].toString()

      @isModel.getItemsByDailySalesId itemIds, dsId, (e, records)=>
        return asyncCb(e) if e?

        if records?.length > 0
          saleItems = records
          return asyncCb()

        #if new, get the last closing as current opening
        @dsModel.getPrevious dsRecord['date'], dsRecord['shift'], (e, prevDSRecord)=>
          return asyncCb(e) if e?

          return asyncCb(null, []) unless prevDSRecord?

          @isModel.getItemsByDailySalesId itemIds, prevDSRecord['_id'].toString(), (e, records)->
            return asyncCb(e) if e?

            saleItems = records
            for saleItem in saleItems
              saleItem['opening'] = saleItem['closing']
              saleItem['closing'] = 0
              saleItem['testing'] = 0

            return asyncCb()

    tasks = [_getOtherItems, _getDailySales, _getOtherItemSales]
    async.series tasks, (e, result)=>
      return cb.apply @, [e] if e?

      for other in others
        saleItem = _.find saleItems, (temp)->
          return temp['item_id'] is other['_id']?.toString()
        
        if saleItem?
          other['opening'] = saleItem['opening']
          other['add'] = saleItem['add']
          other['closing'] = saleItem['closing']
          other['testing'] = saleItem['testing']
        else
          other['opening'] = 0
          other['add'] = 0
          other['closing'] = 0
          other['testing'] = 0

      return cb.apply @, [null, others]

  save: (params, cb)->
    dsId = params['dsId']
    insertItemSales = (sale, itemId, asyncCb)=>
      tmpParams = {
        opening: sale['opening'],
        add: sale['add'],
        closing: sale['closing'],
        testing: sale['testing'],
        sales: sale['sales'],
        rate: sale['rate'],
        amount: sale['amount'],
        item_id: itemId,
        daily_sales_id: dsId
      }
      @isModel.save tmpParams, (e)->
        return asyncCb(e)

    async.eachOf params['items'], insertItemSales, (e)=>
      return cb.apply @, [e] if e?

      params = { others: params['other_total'] }
      @dsModel.updateById dsId, params, (e)=>
        return cb.apply @, [e]

module.exports = SalesOthersBL