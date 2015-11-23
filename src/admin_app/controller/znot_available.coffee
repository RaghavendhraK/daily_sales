Controller = require '../controller'

class NAController extends Controller

  setupRoutes: (server)=>
    server.get '*', (req, res, next)=>
      renderValues = {
        pageTitle: 'Not available'
      }
      renderValues = @mergeDefRenderValues(req, renderValues)
      
      res.status 404
      res.render 'not_available', renderValues

module.exports = NAController