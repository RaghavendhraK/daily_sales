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
    server.post('/sales/step1', @saveStep1)
    # server.get('/sales/:date/:shift', @index)#@checkAuthentication, @index)

  list: (req, res, next)=>
    #To Do: Show the list of saved sales
    res.redirect '/sales/step1'

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Step 1'
      sales_step1: true
    }

    getCashiers = (asyncCb)=>
      @blModel.getCashiers (e, cashiers)=>
        return asyncCb(e) if e?

        cashiers = @setSelectedMustacheDropdownValues cashiers, '_id'
        return asyncCb(null, cashiers)

    getShifts = (asyncCb)=>
      @blModel.getShifts (e, shifts)=>
        return asyncCb(e) if e?

        shifts = @setSelectedMustacheDropdownValues shifts, 'key'
        return asyncCb(null, shifts)

    tasks = {
      cashiers: getCashiers,
      shifts: getShifts
    }
    async.parallel tasks, (e, result)=>
      return next(e) if e?

      renderValues['cashiers'] = result['cashiers']
      renderValues['shifts'] = result['shifts']

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/index', renderValues)

  saveStep1: (req, res, next)=>
    params = req.body
    @blModel.save params, (e, record)=>
      return next(e) if e?
      
      dsId = record['_id'].toString()
      return res.redirect "/sales/fuels/#{dsId}"

module.exports = SalesIndexController