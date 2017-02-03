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

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      return cb.apply @, [null, items]

module.exports = SalesSummaryController