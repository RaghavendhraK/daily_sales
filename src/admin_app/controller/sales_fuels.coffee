Controller = require '../controller'
BLModel = require '../business_logic/sales_fuels'
ItemModel = require '../../models/internal_storage/items'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesFuelController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/fuels/:dsId', @index)
    server.post('/sales/fuels', @saveFuelSales)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Fuels'
      sales_fuels: true
    }

    dsId = req.params['dsId']
    @blModel.getFuelItems dsId, (e, fuels)=>
      return next(e) if e?

      renderValues['fuels'] = fuels

      console.log renderValues['fuels']
      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/fuels', renderValues)

  saveFuelSales: (req, res, next)=>
    res.redirect('/sales/lubes')

module.exports = SalesFuelController