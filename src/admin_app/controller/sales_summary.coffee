Controller = require '../controller'
BLModel = require '../business_logic/sales_summary'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesSummaryController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/summary/:dsId', @index)
    server.post('/sales/summary/:dsId', @saveSummary)

  index: (req, res, next)=>
    dsId = req.params['dsId']
    renderValues = {
      page_title: 'Sales::Summary'
      sales_summary: true
      ds_id: dsId
    }

    @blModel.getSummary dsId, (e, dsRecord)=>
      return next(e) if e?

      renderValues['summary'] = dsRecord

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/summary', renderValues)

  saveSummary: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      return res.redirect('/sales')

module.exports = SalesSummaryController