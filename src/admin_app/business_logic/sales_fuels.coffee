ItemModel = require '../../models/internal_storage/items'
ISModel = require '../../models/internal_storage/item_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesFuelsBL

  constructor: ()->
    @itemModel = new ItemModel
    @isModel = new ISModel
    @dsModel = new DSModel

  getFuelItems: (dsId, cb)->
    fuels = []
    _getFuelItems = (asyncCb)=>
      @itemModel.getFuels (e, records)->
        return asyncCb(e) if e?
        fuels = records
        return asyncCb()
    
    dsRecord = {}
    _getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e) if e?
        dsRecord = record
        return asyncCb()

    saleItems = []
    _getFuelItemSales = (asyncCb)=>
      itemIds = []
      for temp in fuels
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

    tasks = [_getFuelItems, _getDailySales, _getFuelItemSales]
    async.series tasks, (e)=>
      return cb.apply @, [e] if e?

      for fuel in fuels
        saleItem = _.find saleItems, (temp)->
          return temp['item_id'] is fuel['_id']?.toString()
        
        if saleItem?
          fuel['opening'] = saleItem['opening']
          fuel['closing'] = saleItem['closing']
          fuel['testing'] = saleItem['testing']
        else
          fuel['isOpeningEditable'] = true
          fuel['opening'] = 0
          fuel['closing'] = 0
          fuel['testing'] = 0

      return cb.apply @, [null, fuels]

  save: (params, cb)->
    dsId = params['dsId']
    insertItemSales = (sale, itemId, asyncCb)=>
      tmpParams = {
        opening: sale['opening'],
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

      tmpParams = { fuels: params['fuel_total'] }
      @dsModel.updateById dsId, tmpParams, (e)=>
        return cb.apply @, [e]

module.exports = SalesFuelsBL