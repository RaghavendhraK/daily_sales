Controller = require '../controller'

class NAController extends Controller

  setupRoutes: (server)=>
    server.get '*', (req, res, next)=>
      res.status 404
      res.render 'not_available', @mergeDefRenderValues({
        pageTitle:"Not available"
      })

module.exports = NAController