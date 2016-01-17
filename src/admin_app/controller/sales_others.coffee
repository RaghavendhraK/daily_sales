Controller = require '../controller'
ItemModel = require '../../models/internal_storage/items'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesOtherController extends Controller

  constructor: ()->
    @itemModel = new ItemModel
    @dsModel = new DailySalesModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/others', @index)
    server.post('/sales/others', @saveOtherSales)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Others'
      sales_others: true
    }

    tasks = {
      items: @_getItems.bind(@)
    }

    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['fuels'] = results['items']['fuel']

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/others', renderValues)

  saveOtherSales: (req, res, next)=>
    res.redirect('/sales/expenses')

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      return cb.apply @, [null, items]

module.exports = SalesOtherController