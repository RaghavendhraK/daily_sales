Controller = require '../controller'
ItemModel = require '../../models/internal_storage/items'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesExpensesController extends Controller

  constructor: ()->
    @itemModel = new ItemModel
    @dsModel = new DailySalesModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/expenses', @index)
    server.post('/sales/expenses', @saveCFSales)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Expenses'
      sales_expenses: true
    }

    tasks = {
      items: @_getItems.bind(@)
    }

    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['fuels'] = results['items']['fuel']

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/expenses', renderValues)

  saveCFSales: (req, res, next)=>
    res.redirect('/sales/receipts')

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      return cb.apply @, [null, items]

module.exports = SalesExpensesController