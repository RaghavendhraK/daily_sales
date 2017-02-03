InternalStorageModel = require './index'

class AccountSales extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'account_id': 'String'
        'info': 'String'
        'ref_no': 'String'
        'amount': 'Number'
        'daily_sales_id': 'String'
        'created_dt': 'Date'
        'updated_dt': 'Date'
      }
      table : 'account_sales'
      id: '_id'
    }
    return @schema

  getByDailySalesId: (dailySalesId, cb)->
    filters = {daily_sales_id: dailySalesId}
    @getByFilters filters, (e, accountSales)=>
      return cb.apply @, [e, accountSales]

  getAccountsByDailySalesId: (accountIds, dailySalesId, cb)->
    filters = {
      account_id: {$in: accountIds}
      daily_sales_id: dailySalesId
    }
    @getByFilters filters, (e, accountSales)=>
      return cb.apply @, [e, accountSales]

  save: (params, cb)->
    filters = {
      daily_sales_id: params['daily_sales_id']
      account_id: params['account_id']
      info: params['info']
      ref_no: params['ref_no']
    }
    @upsert filters, params, (e)=>
      return cb.apply @, [e]

module.exports = AccountSales