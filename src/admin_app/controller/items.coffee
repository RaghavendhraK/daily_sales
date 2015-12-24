Controller = require '../controller'
ItemModel = require '../../models/internal_storage/items'
Constant = require '../../helpers/constant'

_ = require 'underscore'
moment = require 'moment'
util = require 'util'

class ItemsController extends Controller
  constructor: ()->
    super()
    @itemModel = new ItemModel

  setupRoutes: (server)=>
    server.get('/items', @index)#@checkAuthentication, @index)
    server.get('/add-item', @renderAddItem)#@checkAuthentication, @renderAddItem)
    server.post('/add-item', @addItem)#@checkAuthentication, @addItem)
    server.get('/edit-item/:itemId', @renderEditItem)#@checkAuthentication, @renderEditItem)
    server.post('/edit-item/:itemId', @editItem)#@checkAuthentication, @editItem)
    server.get('/delete-item/:itemId', @deleteItem)#@checkAuthentication, @deleteItem)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Items'
    }

    @itemModel.getAllItems (e, items)=>
      return next(e) if e?

      renderValues['items'] = @_formatItems items

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(req, renderValues)

      res.render('items/index', renderValues)

  _formatItems: (items)->
    _.each items, (item)->
      itemType = _.findWhere Constant.ITEM_TYPES, {key: item['item_type']}
      item['item_type'] = itemType?['value']

      item['updated_dt'] = moment(item['updated_dt']).format(Constant.DATE_FORMAT)
    
    return items

  renderAddItem: (req, res, next)=>
    renderValues = {
      page_title: 'Items :: Add'
    }
    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['item'] = req.body

    @_renderAddEdit req, res, renderValues

  renderEditItem: (req, res, next)=>
    renderValues = {
      page_title: 'Items :: Edit'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['item'] = req.body
      renderValues['item']['_id'] = req.params.itemId
      return @_renderAddEdit req, res, renderValues

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
    @itemModel.create req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
          errors: e.errors
        }
        req.flash 'flash_messages', message
        return @renderAddItem req, res, next
      else
        itemName = req.body.item_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ITEM_ADDED_SUCCESSFULLY, itemName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/items')

  editItem: (req, res, next)=>
    itemId = req.params['itemId']
    
    @itemModel.updateById itemId, req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
          errors: e.errors
        }
        req.flash 'flash_messages', message
        return @renderEditItem req, res, next
      else
        itemName = req.body.item_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ITEM_EDITED_SUCCESSFULLY, itemName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/items')

  deleteItem: (req, res, next)=>
    itemId = req.params['itemId']
    
    @itemModel.deleteById itemId, (e, record)->
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
      else
        itemName = record?['item_name']
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ITEM_DELETED_SUCCESSFULLY, itemName)
        }
        req.flash 'flash_messages', message
      
      return res.redirect('/items')

module.exports = ItemsController