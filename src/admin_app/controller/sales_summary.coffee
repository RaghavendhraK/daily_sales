Controller = require '../controller'
ItemModel = require '../../models/internal_storage/items'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesSummaryController extends Controller

  constructor: ()->
    @itemModel = new ItemModel
    @dsModel = new DailySalesModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/summary', @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Summary'
      sales_summary: true
    }

    tasks = {
      items: @_getItems.bind(@)
    }

    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['fuels'] = results['items']['fuel']

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/summary', renderValues)

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      return cb.apply @, [null, items]

module.exports = SalesSummaryController