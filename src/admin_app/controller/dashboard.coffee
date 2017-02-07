Controller = require '../controller'

class DashboardController extends Controller
  constructor: ()->
    super()

  setupRoutes: (server)=>
    server.get('/', @redirect)

  redirect: (req, res, next)->
    res.redirect '/sales'

module.exports = DashboardController