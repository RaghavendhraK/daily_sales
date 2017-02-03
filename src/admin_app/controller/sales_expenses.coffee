Controller = require '../controller'
BLModel = require '../business_logic/sales_expenses'

_ = require 'underscore'

class SalesExpenseController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/expenses/:dsId', @index)
    server.post('/sales/expenses/:dsId', @saveExpenseSales)#@checkAuthentication, @index)

  _getExpenseAccounts: (req, cb)=>
    returnValues = {}

    dsId = req.params['dsId']
    returnValues['ds_id'] = dsId
    
    unless _.isEmpty(req.body)
      returnValues['expenses'] = _.values(req.body['accounts'])
      returnValues['expense_total'] = req.body['expense_total']
      return cb(null, returnValues)
    else
      @blModel.getExpenseAccounts dsId, (e, expenses)->
        return cb(e) if e?

        returnValues['expenses'] = expenses
        return cb(null, returnValues)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Expenses'
      sales_expenses: true
    }

    @_getExpenseAccounts req, (e, result)=>
      return next(e) if e?

      renderValues = _.extend renderValues, result

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/expenses', renderValues)

  saveExpenseSales: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      dsId = req.body['dsId']
      return res.redirect("/sales/receipts/#{dsId}")

module.exports = SalesExpenseController