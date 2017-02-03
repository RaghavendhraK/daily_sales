AccountModel = require '../../models/internal_storage/accounts'
ASModel = require '../../models/internal_storage/account_sales'
DSModel = require '../../models/internal_storage/daily_sales'

async = require 'async'
_ = require 'underscore'

class SalesReceiptsBL

  constructor: ()->
    @accountModel = new AccountModel
    @asModel = new ASModel
    @dsModel = new DSModel

  getReceiptAccounts: (dsId, cb)->
    receipts = []
    _getReceiptAccounts = (asyncCb)=>
      @accountModel.getReceipts (e, records)->
        return asyncCb(e) if e?
        receipts = records
        return asyncCb()
    
    dsRecord = {}
    _getDailySales = (asyncCb)=>
      @dsModel.getById dsId, (e, record)->
        return asyncCb(e) if e?
        dsRecord = record
        return asyncCb()

    saleAccounts = []
    _getReceiptAccountSales = (asyncCb)=>
      accountIds = []
      for temp in receipts
        accountIds.push temp['_id'].toString()

      @asModel.getAccountsByDailySalesId accountIds, dsId, (e, records)->
        return asyncCb(e) if e?

        saleAccounts = records
        return asyncCb()

    tasks = [_getReceiptAccounts, _getDailySales, _getReceiptAccountSales]
    async.series tasks, (e, result)=>
      return cb.apply @, [e] if e?

      for receipt in receipts
        saleAccount = _.find saleAccounts, (temp)->
          return temp['account_id'] is receipt['_id']?.toString()
        
        if saleAccount?
          receipt['info'] = saleAccount['info']
          receipt['ref_no'] = saleAccount['ref_no']
          receipt['amount'] = saleAccount['amount']
        else
          receipt['info'] = ''
          receipt['ref_no'] = ''
          receipt['amount'] = 0

      return cb.apply @, [null, receipts]

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

      tmpParams = { receipts: params['receipt_total'] }
      @dsModel.updateById dsId, tmpParams, (e)=>
        return cb.apply @, [e]

module.exports = SalesReceiptsBL