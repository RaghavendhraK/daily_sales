Controller = require '../controller'
AuditLogModel = require '../../models/internal_storage/audit_log'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'
url = require 'url'

ObjectID = require('mongodb').ObjectID

class AuditLogController extends Controller

  constructor: ()->
    super()
    @auditLogModel = new AuditLogModel

  setupRoutes: (server)=>
    server.get('/audit-logs', @checkAuthentication, @index)

  _formatAuditLogs: (logs, cb)=>
    _.each logs, (log)->
      log['logged_dt'] = moment(log['logged_dt']).format('DD MMM YYYY<br/> hh:mm:ss a')
      
      details = {}
      details['params'] = JSON.stringify log['params'], null, 4 if log['params']?
      details['headers'] = JSON.stringify log['headers'], null, 4 if log['headers']?
      details['response'] = JSON.stringify log['response'], null, 4 if log['response']?

      log['details'] = details if Object.keys(details).length > 0

    return cb.apply @, [null, logs]

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Audit Logs'
    }

    from = req.query.from
    to = req.query.to
    page = parseInt(req.query.page)
    page = 1 if _.isNaN(page)
    perPage = 10

    getUrlWithPagination = (page)=>
      parsedUrl = url.parse req.url, true
      delete parsedUrl['search']
      
      if _.isEmpty(parsedUrl['query'])
        parsedUrl['query'] = { page: page }
      else
        parsedUrl['query']['page'] = page
      return url.format parsedUrl

    getLogs = (loopCb)=>
      @auditLogModel.getLogsWithPagination from, to, page, perPage, (e, logs)->
        return loopCb(e) if e?

        totalPage = Math.ceil(logs['total']/perPage)
        pages = {
          page: page
          per_page: perPage
          total_count: logs['total']
          from_count: (((page - 1) * perPage) + 1)
          to_count: (page * perPage)
        }

        if logs['audit_logs'].length < 1
          pages['from_count'] = 0
          pages['to_count'] = 0

        if (pages['from_count'] < 0)
          pages['from_count'] = 0

        if (pages['to_count'] > pages['total_count'])
          pages['to_count'] = pages['total_count']

        if (pages['from_count'] > 1)
          pages['first'] = {href: getUrlWithPagination(1)}
          pages['prev'] = { href: getUrlWithPagination(page - 1) }
        else
          pages['first'] = { disabled: true }
          pages['prev'] = { disabled: true }
        
        if (pages['to_count'] < logs['total'])
          pages['next'] = { href: getUrlWithPagination(page + 1) }
          pages['last'] = { href: getUrlWithPagination(totalPage) }
        else
          pages['next'] = { disabled: true }
          pages['last'] = { disabled: true }

        return loopCb(null, {
          pages: pages
          audit_logs: logs['audit_logs']
        })

    tasks = {
      logDetails: getLogs
    }

    isCbCalled = false
    async.parallel tasks, (e, results)=>
      return if isCbCalled
      return next(e) if e?
      isCbCalled = true

      auditLogs = results['logDetails']['audit_logs']

      @_formatAuditLogs auditLogs, (e, formattedLogs)=>
        return loopCb(e) if e?

        renderValues['audit_logs'] = formattedLogs
        renderValues['pages'] = results['logDetails']['pages']

        renderValues['fromDate'] = from
        renderValues['toDate'] = to
        if _.isEmpty(from) or _.isEmpty(to)
          dateRange = 'All'
        else
          dateRange = from + ' - ' + to
        renderValues['date_range'] = dateRange

        renderValues = @mergeDefRenderValues(req, renderValues)
        res.render 'audit_log', renderValues

module.exports = AuditLogController