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
        if prevRate?
          rates[i]['change'] = (rates[i]['rate'] - prevRate)
          if rates[i]['change'] > 0
            rates[i]['increased'] = true
          else
            rates[i]['decreased'] = true
        prevRate = rates[i]['rate']
    
    return rates

module.exports = RatesController