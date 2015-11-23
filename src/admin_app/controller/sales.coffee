Controller = require '../controller'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class SalesController extends Controller

  constructor: ()->
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
      renderValues['fuels'] = results['items']['fuels']
      renderValues['cashiers'] = results['cashiers']
      renderValues['shifts'] = results['shifts']
      renderValues['date'] = moment().format('DD/MM/YYYY')

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales', renderValues)

  saveSales: (req, res, next)=>
    console.log req.body
    res.redirect '/sales'

  _getCashiers: (cb)->
    cashiers = [{
      key: 'kumar'
      value: 'Kumar'
    }, {
      key: 'mahesh'
      value: 'Mahesh'
    }, {
      key: 'ramesh'
      value: 'Ramesh'
    }]
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
    items = {
      fuels: [{
        _id: '1345'
        item_name: 'MS I'
        item_order: 1
        item_type: 'Fuel'
        opening_reading: '200015'
        closing_reading: '200020'
        rate: '50.5'
        sales: '5'
        amount: '750.00'
      }, {
        _id: '1346'
        item_name: 'HSD I'
        item_order: 2
        item_type: 'Fuel'
        opening_reading: '123456'
        closing_reading: '123946'
        rate: '34.56'
        sales: '490'
        amount: '750.00'
      },{
        _id: '1347'
        item_name: 'HSD II'
        item_order: 3
        item_type: 'Fuel'
        opening_reading: '123456'
        closing_reading: '123946'
        rate: '34.56'
        sales: '490'
        amount: '750.00'
      }]
      , lubes: [{
        _id: '1234'
        item_name: '2T 20ml'
        item_order: 1
        item_type: 'Lubes'
        opening_stock: '200'
        closing_stock: '125'
        rate: '10'
        sales: '75'
        amount: '750.00'
      },{
        _id: '1235'
        item_name: '2T 40ml'
        item_order: 2
        item_type: 'Lubes'
        opening_stock: 120
        closing_stock: 104
        rate: 20
        sales: 16
        amount: '320.00'
      },{
        _id: '1236'
        item_name: '4T 1l'
        item_order: 3
        item_type: 'Lubes'
        opening_stock: 24
        closing_stock: 21
        rate: 278
        sales: 3
        amount: '834.00'
      },{
        _id: '1237'
        item_name: 'CF4 15l'
        item_order: 4
        item_type: 'Lubes'
        opening_stock: 5
        closing_stock: 4
        rate: 1000
        sales: 1
        amount: '1000.00'
      }]
    }
    return cb.apply @, [null, items]

module.exports = SalesController