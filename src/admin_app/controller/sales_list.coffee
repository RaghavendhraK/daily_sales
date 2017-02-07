Controller = require '../controller'
BLModel = require '../business_logic/sales_list'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesListController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales', @list)
    server.post('/sales', @list)#@checkAuthentication

  list: (req, res, next)=>
    renderValues = {
      page_title: 'Sales list'
    }

    fromDate = moment().startOf('month')
    toDate = moment()

    if req.body['from_date']?
      req.session['from_date'] = req.body['from_date']
      req.session['to_date'] = req.body['to_date']

    if req.session['from_date']?
      fromDate = moment(req.session['from_date'], 'DD/MM/YYYY')
      toDate = moment(req.session['to_date'], 'DD/MM/YYYY')

    params = {
      from_date: fromDate.format('YYYY-MM-DD')
      to_date: toDate.format('YYYY-MM-DD')
    }
    @blModel.getSales params, (e, records)=>
      return next(e) if e?

      renderValues['sales'] = records

      renderValues['from_date'] = fromDate.format('DD/MM/YYYY')
      renderValues['to_date'] = toDate.format('DD/MM/YYYY')

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/list', renderValues)

module.exports = SalesListController