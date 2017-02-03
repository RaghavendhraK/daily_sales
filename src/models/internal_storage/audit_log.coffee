InternalStorageModel = require './index'

validator = require '../../lib/validator'
Util = require '../../util'

class AuditLog extends InternalStorageModel

  getSchema: ()->
    @schema = {
      fields: {
        'logged_dt': 'Date'
        'user_id': 'ObjectID'
        'cust_id': 'ObjectID'
        'admin_id':'ObjectID'
        'action': 'String'
        'remote_address': 'String'
        'path': 'String'
        'method': 'String'
        'params': 'Object'
        'headers': 'Object'
        'status_code': 'Number'
        'response': 'String'
        'response_time': 'Number'
      }
      table: 'audit_logs'
      id: '_id'
    } unless @schema?
    return @schema

  getObscFields: ()->
    return ['password', 'confirm_password', 'auth_token']

  log: (req, res, cb)->
    body = res._body

    #Response time
    latency = res.get('Response-Time')
    latency = Date.now() - req._time if (typeof (latency) isnt 'number')

    #Logged-In User-Id
    if req.user.admin_id?
      adminId = req.user['admin_id']
    else
      adminId = null
    
    if req.user?
      userId = req.user['_id']
      custId = req.user['cust_id']
    else
      userId = null
      custId = null

    path = req.getPath()
    if req.action?.length > 0
    then action = req.action
    else action = path

    obscFields = @getObscFields()
    params = Util.obscureCredentials(req.params, obscFields)
    headers = Util.obscureCredentials(req.headers, obscFields)
    response = Util.obscureCredentials(body, obscFields)

    remoteAddress = "#{req.connection.remoteAddress}:#{req.connection.remotePort}"
    
    logFields = {
      logged_dt: new Date
      user_id: userId
      cust_id: custId
      admin_id:adminId
      action: action
      remote_address: remoteAddress
      path: path
      method: req.method
      params: params
      headers: headers
      status_code: res.statusCode
      response: response
      response_time: latency
    }

    @create logFields, (e)->
      return cb(e)

  getLogsWithPagination: (from, to, page, perPage, cb)->
    from = validator.sanitize(from)
    to = validator.sanitize(to)

    page = parseInt(page)
    page = 1 if isNaN(page)

    intPerPage = parseInt(perPage)
    perPage = 10 if isNaN(perPage)

    filters = {}
    filters['cust_id'] = custId if custId?.length > 0
    filters['user_id'] = userId if userId?.length > 0
    if from?.length > 0 and to?.length > 0
      from = new Date("#{from} 00:00:00")
      to = new Date("#{to} 23:59:59")

      filters['$and'] = [
        {logged_dt: {$gte: from}}
        {logged_dt: {$lte: to}}
      ]

    options = {
      sort: {'logged_dt': 'DESC'}
      limit: {
        offset: ((page-1) * perPage)
        count: perPage
      }
    }

    @getByFilters filters, options, (e, auditLogs)=>
      return cb(e, null) if e?

      @count filters, (eCnt, count)->
        return cb(eCnt, null) if eCnt?

        return cb(null, {
          total: count,
          audit_logs: auditLogs
        })

  getCountByHoursSinceDate: (sinceDate, cb)->
    pipes = [
      { $match : { cust_id: { $ne:null}, logged_dt : { $gte : sinceDate}}},
      { $sort : { cust_id: 1, logged_dt: -1 }},
      {
        $group : {
          _id : {
            cust_id: "$cust_id",
            year: { $year: "$logged_dt" },
            month: { $month: "$logged_dt" },
            day: { $dayOfMonth: "$logged_dt" },
            hour: { $hour: "$logged_dt" }
          },
          count: { $sum: 1 }
        }
      }
    ]
    @getDataAdapter().aggregate pipes, (e, records)->
      return cb(e, records)

module.exports = AuditLog