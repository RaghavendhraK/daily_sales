Controller = require '../controller'
RateModel = require '../../models/internal_storage/rates'
ItemModel = require '../../models/internal_storage/items'
Constant = require '../../helpers/constant'

_ = require 'underscore'
async = require 'async'
moment = require 'moment'

class RatesController extends Controller
  constructor: ()->
    super()
    @rateModel = new RateModel

  setupRoutes: (server)=>
    server.get('/rates/:itemId', @index)#@checkAuthentication, @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Rates'
    }

    itemId = req.params['itemId']

    getItem = (asyncCb)->
      itemModel = new ItemModel
      itemModel.getById itemId, (e, item)->
        return asyncCb(e) if e?
        
        renderValues['item'] = item
        return asyncCb()

    getRates = (asyncCb)=>
      @rateModel.getByItemId itemId, (e, rates)=>
        return asyncCb(e) if e?

        renderValues['rates'] = @_formatRates(rates)
        return asyncCb()

    isCbCalled = false
    async.parallel [getItem, getRates], (e)=>
      if e?
        return if isCbCalled
        return next(e)

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('items/rates', renderValues)

  _formatRates: (rates)->
    count = rates.length
    if count > 0
      prevRate = null
      for i in [(count-1)..0]
        rates[i]['created_dt'] = moment(rates[i]['created_dt']).format('YYYY-MM-DD')
        rates[i]['change'] = (rates[i]['rate'] - prevRate) if prevRate?
        prevRate = rates[i]['rate']
    
    return rates

  renderAddItem: (req, res, next)=>
    renderValues = {
      page_title: 'Items :: Add'
    }

    @_renderAddEdit req, res, renderValues

  renderEditItem: (req, res, next)=>
    renderValues = {
      page_title: 'Items :: Edit'
    }

    @itemModel.getById req.params.itemId, (e, item)=>
      return next(e) if e?

      renderValues['item'] = item

      @_renderAddEdit req, res, renderValues

  _renderAddEdit: (req, res, renderValues)->
    renderValues['item_types'] = @setSelectedMustacheDropdownValues Constant.ITEM_TYPES, 'key', renderValues['item']?['item_type']
    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(req, renderValues)
    res.render('items/add-edit', renderValues)

  addItem: (req, res, next)=>
    @itemModel.create req.body, (e)->
      if e?
        message = {
          type: 'error'
          message: e.message
        }
      else
        item_name = req.body.item_name
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.ITEM_ADDED_SUCCESSFULLY
        }
      req.flash 'flash_messages', message
      res.redirect('/items')

  editItem: (req, res, next)=>
    itemId = req.params['itemId']
    
    @itemModel.updateById itemId, req.body, (e)->
      req.flash 'flash_messages', {
        type: 'error'
        message: 'Saved!!'
      }
      res.redirect('/items')

module.exports = RatesController