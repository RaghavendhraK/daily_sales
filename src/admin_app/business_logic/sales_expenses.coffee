AccountModel = require '../../models/internal_storage/accounts'
ASModel = require '../../models/internal_storage/account_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesExpensesBL

  constructor: ()->
    @accountModel = new AccountModel
    @asModel = new ASModel
    @dsModel = new DSModel

  getExpenseAccounts: (dsId, cb)->
    expenses = []
    _getExpenseAccounts = (asyncCb)=>
      @accountModel.getExpenses (e, records)->
        return asyncCb(e) if e?
        expenses = records
        return asyncCb()
    
    dsRecord = {}
    _getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e) if e?
        dsRecord = record
        return asyncCb()

    saleAccounts = []
    _getExpenseAccountSales = (asyncCb)=>
      accountIds = []
      for temp in expenses
        accountIds.push temp['_id'].toString()

      @asModel.getAccountsByDailySalesId accountIds, dsId, (e, records)->
        return asyncCb(e) if e?

        saleAccounts = records
        return asyncCb()

    tasks = [_getExpenseAccounts, _getDailySales, _getExpenseAccountSales]
    async.series tasks, (e, result)=>
      return cb.apply @, [e] if e?

      for expense in expenses
        saleAccount = _.find saleAccounts, (temp)->
          return temp['account_id'] is expense['_id']?.toString()
        
        if saleAccount?
          expense['info'] = saleAccount['info']
          expense['ref_no'] = saleAccount['ref_no']
          expense['amount'] = saleAccount['amount']
        else
          expense['info'] = ''
          expense['ref_no'] = ''
          expense['amount'] = 0

      return cb.apply @, [null, expenses]

  save: (params, cb)->
    dsId = params['dsId']
    insertAccountSales = (sale, accountId, asyncCb)=>
      tmpParams = {
        info: sale['info'],
        ref_no: sale['ref_no'],
        amount: sale['amount'],
        account_id: accountId,
        daily_sales_id: dsId
      }
      @asModel.save tmpParams, (e)->
        return asyncCb(e)

    async.eachOf params['accounts'], insertAccountSales, (e)=>
      return cb.apply @, [e] if e?

      tmpParams = { expenses: params['expense_total'] }
      @dsModel.updateById dsId, tmpParams, (e)=>
        return cb.apply @, [e]

module.exports = SalesExpensesBL