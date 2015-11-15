AdminappServer = require './server'

appServer = new AdminappServer

appServer.createServer()
appServer.setControllerPath(__dirname + '/controller')
appServer.setDefAppLevelVars()
appServer.setupRoutes()
appServer.handleException()

appServer.listen(config.get('port.admin_app'))