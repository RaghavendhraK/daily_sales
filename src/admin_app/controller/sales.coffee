Controller = require '../controller'
StaffModel = require '../../models/internal_storage/staffs'
ItemModel = require '../../models/internal_storage/items'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesController extends Controller

  constructor: ()->
    @itemModel = new ItemModel
    @staffModel = new StaffModel
    super()

  setupRoutes: (server)=>
    server.get('/sales', @index)#@checkAuthentication, @index)
    server.post('/save-sales', @saveSales)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales'
    }

    tasks = {
      items: @_getItems.bind(@)
      , cashiers: @_getCashiers.bind(@)
      , shifts: @_getShifts.bind(@)
    }

    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['lubes'] = results['items']['lubes']
      renderValues['fuels'] = results['items']['fuel']
      renderValues['cashiers'] = results['cashiers']
      renderValues['shifts'] = results['shifts']
      renderValues['date'] = moment().format('DD/MM/YYYY')

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales', renderValues)

  saveSales: (req, res, next)->
    res.redirect '/sales'

  _getCashiers: (cb)->
    @staffModel.getCashiers (e, records)=>
      return cb.apply @, [e] if e?

      cashiers = []
      _.each records, (record)->
        cashiers.push {
          key: record['_id'].toString()
          value: record['staff_name']
        }

      return cb.apply @, [null, cashiers]

  _getShifts: (cb)->
    shifts = [{
      key: 's1'
      value: 'I'
    }, {
      key: 's2'
      value: 'II'
    }, {
      key: 's3'
      value: 'III'
    }]
    return cb.apply @, [null, shifts]

  _getItems: (cb)->
    @itemModel.getAll (e, items)=>
      return cb.apply @, [e] if e?

      items = _.groupBy items, 'item_type'

      # items = {
      #   fuels: [{
      #     _id: '1345'
      #     item_name: 'MS I'
      #     item_order: 1
      #     item_type: 'Fuel'
      #     opening_reading: '200015'
      #     closing_reading: '200020'
      #     rate: '50.5'
      #     sales: '5'
      #     amount: '750.00'
      #   }]
      #   , lubes: [{
      #     _id: '1234'
      #     item_name: '2T 20ml'
      #     item_order: 1
      #     item_type: 'Lubes'
      #     opening_stock: '200'
      #     closing_stock: '125'
      #     rate: '10'
      #     sales: '75'
      #     amount: '750.00'
      #   }]
      # }
      return cb.apply @, [null, items]

module.exports = SalesController