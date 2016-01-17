Controller = require '../controller'
ItemModel = require '../../models/internal_storage/items'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesLubeController extends Controller

  constructor: ()->
    @itemModel = new ItemModel
    @dsModel = new DailySalesModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/lubes', @index)
    server.post('/sales/lubes', @saveLubeSales)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Lubes'
      sales_lubes: true
    }

    tasks = {
      items: @_getItems.bind(@)
    }

    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['fuels'] = results['items']['fuel']

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/lubes', renderValues)

  saveLubeSales: (req, res, next)=>
    res.redirect('/sales/others')

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      date = moment()
      @dsModel.getRecent
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
      return cb.apply @, [null, items]

module.exports = SalesLubeController