ItemModel = require '../../models/internal_storage/items'
ISModel = require '../../models/internal_storage/item_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesLubesBL

  constructor: ()->
    @itemModel = new ItemModel
    @isModel = new ISModel
    @dsModel = new DSModel

  getLubeItems: (dsId, cb)->
    lubes = []
    _getLubeItems = (asyncCb)=>
      @itemModel.getLubes (e, records)->
        return asyncCb(e) if e?
        lubes = records
        return asyncCb()
    
    dsRecord = {}
    _getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e) if e?
        dsRecord = record
        return asyncCb()

    saleItems = []
    _getLubeItemSales = (asyncCb)=>
      itemIds = []
      for temp in lubes
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

    tasks = [_getLubeItems, _getDailySales, _getLubeItemSales]
    async.series tasks, (e, result)=>
      return cb.apply @, [e] if e?

      for lube in lubes
        saleItem = _.find saleItems, (temp)->
          return temp['item_id'] is lube['_id']?.toString()
        
        if saleItem?
          lube['opening'] = saleItem['opening']
          lube['add'] = saleItem['add']
          lube['closing'] = saleItem['closing']
          lube['testing'] = saleItem['testing']
        else
          lube['opening'] = 0
          lube['add'] = 0
          lube['closing'] = 0
          lube['testing'] = 0

      return cb.apply @, [null, lubes]

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

      tmpParams = { lubes: params['lube_total'] }
      @dsModel.updateById dsId, tmpParams, (e)=>
        return cb.apply @, [e]

module.exports = SalesLubesBL