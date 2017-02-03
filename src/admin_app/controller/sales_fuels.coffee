Controller = require '../controller'
BLModel = require '../business_logic/sales_fuels'

_ = require 'underscore'

class SalesFuelController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/fuels/:dsId', @index)
    server.post('/sales/fuels/:dsId', @saveFuelSales)#@checkAuthentication, @index)

  _getFuelItems: (req, cb)=>
    returnValues = {}

    dsId = req.params['dsId']
    returnValues['ds_id'] = dsId
    
    unless _.isEmpty(req.body)
      returnValues['fuels'] = _.values(req.body['items'])
      returnValues['fuel_total'] = req.body['fuel_total']
      return cb(null, returnValues)
    else
      @blModel.getFuelItems dsId, (e, fuels)->
        return cb(e) if e?

        returnValues['fuels'] = fuels
        return cb(null, returnValues)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Fuels'
      sales_fuels: true
    }

    @_getFuelItems req, (e, result)=>
      return next(e) if e?

      renderValues = _.extend renderValues, result

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/fuels', renderValues)

  saveFuelSales: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      dsId = req.body['dsId']
      return res.redirect("/sales/lubes/#{dsId}")

module.exports = SalesFuelController