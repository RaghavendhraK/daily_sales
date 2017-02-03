Controller = require '../controller'
AccountModel = require '../../models/internal_storage/accounts'
Constant = require '../../helpers/constant'

_ = require 'underscore'
moment = require 'moment'
util = require 'util'

class AccountsController extends Controller
  constructor: ()->
    super()
    @accountModel = new AccountModel

  setupRoutes: (server)=>
    server.get('/accounts', @index)#@checkAuthentication, @index)
    server.get('/add-account', @renderAddAccount)#@checkAuthentication, @renderAddAccount)
    server.post('/add-account', @addAccount)#@checkAuthentication, @addAccount)
    server.get('/edit-account/:accountId', @renderEditAccount)#@checkAuthentication, @renderEditAccount)
    server.post('/edit-account/:accountId', @editAccount)#@checkAuthentication, @editAccount)
    server.get('/delete-account/:accountId', @deleteAccount)#@checkAuthentication, @deleteAccount)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Accounts'
    }

    @accountModel.getAllAccounts (e, accounts)=>
      return next(e) if e?

      renderValues['accounts'] = @_formatAccounts accounts

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(req, renderValues)

      res.render('accounts/index', renderValues)

  _formatAccounts: (accounts)->
    _.each accounts, (account)->
      accountType = _.findWhere Constant.ACCOUNT_TYPES, {key: account['account_type']}
      account['account_type'] = accountType?['value']

      account['updated_dt'] = moment(account['updated_dt']).format(Constant.DATE_FORMAT)
    
    return accounts

  renderAddAccount: (req, res, next)=>
    renderValues = {
      page_title: 'Accounts :: Add'
    }
    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['account'] = req.body

    @_renderAddEdit req, res, renderValues

  renderEditAccount: (req, res, next)=>
    renderValues = {
      page_title: 'Accounts :: Edit'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['account'] = req.body
      renderValues['account']['_id'] = req.params.accountId
      return @_renderAddEdit req, res, renderValues

    @accountModel.getById req.params.accountId, (e, account)=>
      return next(e) if e?

      renderValues['account'] = account
      @_renderAddEdit req, res, renderValues

  _renderAddEdit: (req, res, renderValues)->
    renderValues['account_types'] = @setSelectedMustacheDropdownValues Constant.ACCOUNT_TYPES, 'key', renderValues['account']?['account_type']
    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(req, renderValues)
    res.render('accounts/add-edit', renderValues)

  addAccount: (req, res, next)=>
    @accountModel.create req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
          errors: e.errors
        }
        req.flash 'flash_messages', message
        return @renderAddAccount req, res, next
      else
        accountName = req.body.account_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ACCOUNT_ADDED_SUCCESSFULLY, accountName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/accounts')

  editAccount: (req, res, next)=>
    accountId = req.params['accountId']
    
    @accountModel.updateById accountId, req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
          errors: e.errors
        }
        req.flash 'flash_messages', message
        return @renderEditAccount req, res, next
      else
        accountName = req.body.account_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ACCOUNT_EDITED_SUCCESSFULLY, accountName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/accounts')

  deleteAccount: (req, res, next)=>
    accountId = req.params['accountId']
    
    @accountModel.deleteById accountId, (e, record)->
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
      else
        accountName = record?['account_name']
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.ACCOUNT_DELETED_SUCCESSFULLY, accountName)
        }
        req.flash 'flash_messages', message
      
      return res.redirect('/accounts')

module.exports = AccountsController