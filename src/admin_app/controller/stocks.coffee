Controller = require '../controller'
StockModel = require '../../models/internal_storage/stocks'
ItemModel = require '../../models/internal_storage/items'
Constant = require '../../helpers/constant'

_ = require 'underscore'
moment = require 'moment'
async = require 'async'

class StocksController extends Controller
  constructor: ()->
    super()
    @stockModel = new StockModel
    @itemModel = new ItemModel

  setupRoutes: (server)=>
    server.get('/stocks', @checkAuthentication, @index)
    server.get('/stock-receipts', @checkAuthentication, @stockReceipts)
    server.get('/add-stock', @checkAuthentication, @renderAddStock)
    server.post('/add-stock', @checkAuthentication, @addStock)
    # server.get('/delete-stock', @checkAuthentication, @deleteStock)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Stocks'
    }
    items = []
    stocks = []
    getItems = (asyncCb)=>
      filters = {}
      options = {sort: {item_type: 'ASC', item_name: 'ASC'}}
      @itemModel.getByFilters filters, options, (e, items)->
        return asyncCb(e) if e?

        _.each items, (item)->
          item['_id'] = item['_id'].toString()

        return asyncCb()

    getStocks = (asyncCb)=>
      @stockModel.getAllStocks (e, stocks)->
        return asyncCb(e)

    isCbCalled = false
    async.parallel [getItems, getStocks], (e)=>
      if e?
        return next(e) unless isCbCalled
        isCbCalled = true
        return

      renderValues['stocks'] = @_formatStocks items, stocks

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(req, renderValues)

      res.render('stocks/index', renderValues)

  stockReceipts: (req, res, next)=>
    renderValues = {
      page_title: 'Stock Receipts'
    }

    items = []
    stocks = []
    getItems = (asyncCb)=>
      @itemModel.getAllItems (e, items)->
        return asyncCb(e) if e?

        _.each items, (item)->
          item['_id'] = item['_id'].toString()

        return asyncCb()

    getStocks = (asyncCb)=>
      @stockModel.getAllStocks (e, stocks)->
        return asyncCb(e)

    isCbCalled = false
    async.parallel [getItems, getStocks], (e)=>
      if e?
        return next(e) unless isCbCalled
        isCbCalled = true
        return

      renderValues['stocks'] = @_formatStocks stocks, items

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(req, renderValues)

      res.render('stocks/index', renderValues)

  _formatStocks: (items, stocks)->
    _.each items, (item)->
      stocks = _.findWhere stocks, {item_id: item['_id']}
      item['stock'] = stock['balance']
      stock['unit'] = item?['unit']

    return stocks

  renderAddStock: (req, res, next)=>
    renderValues = {
      page_title: 'Stocks :: Add'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['stock'] = req.body

    @_renderAddEdit req, res, renderValues

  renderEditStock: (req, res, next)=>
    renderValues = {
      page_title: 'Stocks :: Edit'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['stock'] = req.body
      renderValues['stock']['_id'] = req.params.stockId
      return @_renderAddEdit req, res, renderValues

    @stockModel.getById req.params.stockId, (e, stock)=>
      return next(e) if e?

      renderValues['stock'] = stock
      @_renderAddEdit req, res, renderValues

  _renderAddEdit: (req, res, renderValues)->
    renderValues['stock_types'] = @setSelectedMustacheDropdownValues Constant.STOCK_TYPES, 'key', renderValues['stock']?['stock_type']
    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(req, renderValues)
    res.render('stocks/add-edit', renderValues)

  addStock: (req, res, next)=>
    @stockModel.create req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStock req, res, next
      else
        stock_name = req.body.stock_name
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.STOCK_ADDED_SUCCESSFULLY
        }
        req.flash 'flash_messages', message
        return res.redirect('/stocks')

  editStock: (req, res, next)=>
    stockId = req.params['stockId']
    
    @stockModel.updateById stockId, req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStock req, res, next
      else
        stock_name = req.body.stock_name
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.STOCK_ADDED_SUCCESSFULLY
        }
        req.flash 'flash_messages', message
        return res.redirect('/stocks')

module.exports = StocksController