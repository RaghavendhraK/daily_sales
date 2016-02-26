ItemModel = require '../../models/internal_storage/items'
ISModel = require '../../models/internal_storage/item_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'

class SalesFuelsBL

  constructor: ()->
    @itemModel = new ItemModel
    @isModel = new ISModel
    @dsModel = new DSModel

  getFuelItems: (dsId, cb)->
    getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e, record)

    getFuelItemSales = (dsRecord, asyncCb)=>
      #if already saved, show the same
      @isModel.getByDailySalesId dsId, (e, saleItems)=>
        return asyncCb(e) if e?

        return asyncCb(null, saleItems) if saleItems?.length > 0

        #if new, get the last closing as current opening
        @isModel.getRecent (e, saleItems)->
          return asyncCb(e) if e?

          return asyncCb() unless saleItems?.length > 0

          for saleItem in saleItems
            saleItem['opening'] = saleItem['closing']
            saleItem['closing'] = ''
            saleItem['testing'] = ''
          return asyncCb(null, saleItems)

    getFuelItems = (saleItems, asyncCb)->
      @itemModel.getFuels (e, fuels)->
        return asyncCb(e) if e?

        for fuel in fuels
          saleItem = _.find saleItems, (temp)->
            return temp['_id'].toString() is fuel['_id'].toString()
          if saleItem?
            fuel['opening'] = saleItem['opening']
            fuel['closing'] = saleItem['closing']
            fuel['testing'] = saleItem['testing']
          else
            fuel['opening'] = 0
            fuel['closing'] = ''
            fuel['testing'] = ''

        return asyncCb(null, fuels)

    tasks = [getDailySales, getFuelItemSales, getFuelItems]
    async.waterfall tasks, (e, fuels)=>
      console.log fuels
      return cb.apply @, [e, fuels]
      # items = {
      #   fuels: [{
      #     _id: '1345'
      #     item_name: 'MS I'
      #     item_order: 1
      #     item_type: 'Fuel'
      #     opening_reading: '200015'
      #     closing_reading: '200020'
      #     rate: '50.5'
      #     sales: '5'
      #     amount: '750.00'
      #   }]
      #   , lubes: [{
      #     _id: '1234'
      #     item_name: '2T 20ml'
      #     item_order: 1
      #     item_type: 'Lubes'
      #     opening_stock: '200'
      #     closing_stock: '125'
      #     rate: '10'
      #     sales: '75'
      #     amount: '750.00'
      #   }]
      # }

module.exports = SalesFuelsBL