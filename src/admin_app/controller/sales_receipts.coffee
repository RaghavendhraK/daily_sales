Controller = require '../controller'
BLModel = require '../business_logic/sales_receipts'

_ = require 'underscore'

class SalesReceiptController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/receipts/:dsId', @index)
    server.post('/sales/receipts/:dsId', @saveReceiptSales)#@checkAuthentication, @index)

  _getReceiptAccounts: (req, cb)=>
    returnValues = {}

    dsId = req.params['dsId']
    returnValues['ds_id'] = dsId
    
    unless _.isEmpty(req.body)
      returnValues['receipts'] = _.values(req.body['accounts'])
      returnValues['receipt_total'] = req.body['receipt_total']
      return cb(null, returnValues)
    else
      @blModel.getReceiptAccounts dsId, (e, receipts)->
        return cb(e) if e?

        returnValues['receipts'] = receipts
        return cb(null, returnValues)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Receipts'
      sales_receipts: true
    }

    @_getReceiptAccounts req, (e, result)=>
      return next(e) if e?

      renderValues = _.extend renderValues, result

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/receipts', renderValues)

  saveReceiptSales: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      dsId = req.body['dsId']
      return res.redirect("/sales/summary/#{dsId}")

module.exports = SalesReceiptController