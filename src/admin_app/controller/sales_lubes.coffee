Controller = require '../controller'
BLModel = require '../business_logic/sales_lubes'

_ = require 'underscore'

class SalesLubeController extends Controller

  constructor: ()->
    @blModel = new BLModel
    super()

  setupRoutes: (server)=>
    server.get('/sales/lubes/:dsId', @index)
    server.post('/sales/lubes/:dsId', @saveLubeSales)#@checkAuthentication, @index)

  _getLubeItems: (req, cb)=>
    returnValues = {}

    dsId = req.params['dsId']
    returnValues['ds_id'] = dsId
    
    unless _.isEmpty(req.body)
      returnValues['lubes'] = _.values(req.body['items'])
      returnValues['lube_total'] = req.body['lube_total']
      return cb(null, returnValues)
    else
      @blModel.getLubeItems dsId, (e, lubes)->
        return cb(e) if e?

        returnValues['lubes'] = lubes
        return cb(null, returnValues)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Sales::Lubes'
      sales_lubes: true
    }

    @_getLubeItems req, (e, result)=>
      return next(e) if e?

      renderValues = _.extend renderValues, result

      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('sales/lubes', renderValues)

  saveLubeSales: (req, res, next)=>
    @blModel.save req.body, (e)=>
      return @index(req, res, next) if e?

      dsId = req.body['dsId']
      return res.redirect("/sales/others/#{dsId}")

module.exports = SalesLubeController