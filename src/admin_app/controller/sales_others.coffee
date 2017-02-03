Controller = require '../controller'
BLModel = require '../business_logic/sales_others'

_ = require 'underscore'

class SalesOtherController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/others/:dsId', @index)
    server.post('/sales/others/:dsId', @saveOtherSales)#@checkAuthentication, @index)

  _getOtherItems: (req, cb)=>
    returnValues = {}

    dsId = req.params['dsId']
    returnValues['ds_id'] = dsId
    
    unless _.isEmpty(req.body)
      returnValues['others'] = _.values(req.body['items'])
      returnValues['other_total'] = req.body['other_total']
      return cb(null, returnValues)
    else
      @blModel.getOtherItems dsId, (e, others)->
        return cb(e) if e?

        returnValues['others'] = others
        return cb(null, returnValues)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Others'
      sales_others: true
    }

    @_getOtherItems req, (e, result)=>
      return next(e) if e?

      renderValues = _.extend renderValues, result

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/others', renderValues)

  saveOtherSales: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      dsId = req.body['dsId']
      return res.redirect("/sales/expenses/#{dsId}")

module.exports = SalesOtherController