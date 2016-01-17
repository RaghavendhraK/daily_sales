Controller = require '../controller'
StaffModel = require '../../models/internal_storage/staffs'
DailySalesModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesIndexController extends Controller

  constructor: ()->
    @staffModel = new StaffModel
    @dsModel = new DailySalesModel
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

    renderValues = @mergeDefRenderValues(req, renderValues)
    res.render('sales/index', renderValues)

  saveStep1: (req, res, next)=>
    res.redirect('/sales/fuels')

module.exports = SalesIndexController