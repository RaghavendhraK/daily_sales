Controller = require '../controller'
AuditLogModel = require '../../models/internal_storage/audit_log'

async = require 'async'
_ = require 'underscore'
moment = require 'moment'

class DashboardController extends Controller
  constructor: ()->
    super()
    @NO_OF_LOGS = 5
    @auditLogModel = new AuditLogModel

  setupRoutes: (server)=>
    server.get('/dashboard', @checkAuthentication, @index)
    server.get('/', @redirect)

  redirect: (req, res, next)->
    res.redirect '/dashboard'

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Dashboard'
    }

    getLogs = (loopCb)=>
      @auditLogModel.getN @NO_OF_LOGS, (e, logs)->
        return loopCb(e) if e?

        _.each logs, (log)->
          log['logged_dt'] = moment(log['logged_dt']).format('DD MMM YYYY<br/> hh:mm:ss a')

        return loopCb(null, logs)
    
    tasks = {
      logs: getLogs
    }
    async.parallel tasks, (e, results)=>
      return next(e) if e?

      renderValues['audit_logs'] = results['logs']

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(renderValues)

      res.render('dashboard', renderValues)

module.exports = DashboardController