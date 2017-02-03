Controller = require '../controller'
BLModel = require '../business_logic/sales_step1'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesIndexController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales', @list)
    server.get('/sales/step1', @index)
    server.get('/sales/step1/:dsId', @index)
    server.post('/sales/step1', @saveStep1)
    # server.get('/sales/:date/:shift', @index)#@checkAuthentication, @index)

  list: (req, res, next)=>
    #To Do: Show the list of saved sales
    res.redirect '/sales/step1'

  index: (req, res, next)=>
    dsId = req.params['dsId']

    renderValues = {
      page_title: 'Sales::Step 1'
      sales_step1: true
      ds_id: dsId
    }

    ds = null
    getDS = (asyncCb)=>
      return asyncCb() unless dsId?

      @blModel.getDailySales dsId, (e, record)->
        return asyncCb(e) if e?

        ds = record
        return asyncCb(null, ds)

    getCashiers = (asyncCb)=>
      @blModel.getCashiers (e, cashiers)=>
        return asyncCb(e) if e?

        cashiers = @setSelectedMustacheDropdownValues cashiers, '_id', ds?['cashier']
        return asyncCb(null, cashiers)

    getShifts = (asyncCb)=>
      @blModel.getShifts (e, shifts)=>
        return asyncCb(e) if e?

        shifts = @setSelectedMustacheDropdownValues shifts, 'key', ds?['shift']
        return asyncCb(null, shifts)

    tasks = {
      daily_sales: getDS,
      cashiers: getCashiers,
      shifts: getShifts
    }
    async.series tasks, (e, result)=>
      return next(e) if e?

      renderValues['cashiers'] = result['cashiers']
      renderValues['shifts'] = result['shifts']
      
      if (ds?)
        renderValues['date'] = moment(ds['date'], 'YYYY-MM-DD').format('DD/MM/YYYY')

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/index', renderValues)

  saveStep1: (req, res, next)=>
    params = req.body
    params['date'] = moment(params['date'], 'DD/MM/YYYY').format('YYYY-MM-DD')
    @blModel.save params, (e, record)->
      return next(e) if e?
      
      dsId = record['_id'].toString()
      return res.redirect "/sales/fuels/#{dsId}"

module.exports = SalesIndexController