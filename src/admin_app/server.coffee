express = require 'express'

bodyParser = require 'body-parser'
qs = require 'qs'

session = require 'express-session'
MongoStore = require('connect-mongo')(session)
helmet = require 'helmet'
csrf = require 'csurf'
flash = require 'connect-flash'
Controller = require './controller'

fs = require 'fs'

class AdminAppServer

  createServer: ()->
    @server = express()

    cookieSettings = {httpOnly: true}
    cookieSettings['maxAge'] = config.get('admin_app_session_expire_time') * 60 * 1000

    mongoStoreOptions = { url: "mongodb://openly:indian@localhost:27017/session" }
    #For Session Management
    @server.use(session({
      secret: config.get('salt')
      resave: true
      saveUninitialized: true
      cookie: cookieSettings
      store: new MongoStore(mongoStoreOptions)
    }))

    #For Messages after redirect
    @server.use(flash())

    @server.use(bodyParser.urlencoded({
      extended: false
    }))
    @server.use(@parseQueryString)
    #to upload files
    # @server.use(multer(dest: config.get('upload_dir_path')))
    #For CSRF validations
    # @server.use(csrf())

    @server.use('/static', express.static(__dirname + '/../../static'))

    @server.engine 'mustache', require 'mustache-express4'
    @server.set 'view engine', 'mustache'
    @server.set 'views', __dirname + '/views/'
    @server.set 'partials', __dirname + '/views/partials'
        
    #To handle exceptions
    @server.use(require('express-domain-middleware'))

    @server.use(helmet())
    #to trust the reverse proxy
    @server.set('trust proxy', 1)

  listen: (port, cb)->
    throw new Error 'Server is not created yet' unless @server?
    
    Log.info("Admin App Started at port #{port}")
    @server.listen port, cb

  handleException: ()->
    throw new Error 'Server is not created yet' unless @server?
    
    controller = new Controller()

    @server.use (err, req, res, next)->
      console.log err
      return next() unless err?

      if (err.code == 'EBADCSRFTOKEN')
        res.status(403)
        err.message = CONFIGURED_MESSAGES.CSRF_TOKEN_FAIL
      else
        res.status(500)
        Log.error(err)
        
      renderValues = { page_title: 'Error', message: err.message }
      renderValues = controller.mergeDefRenderValues(renderValues)
      res.render '500', renderValues

      #To DO: restart the application, as it catches uncaught exceptions also

  #We can set the application level variables here
  setDefAppLevelVars: ()->
    throw new Error 'Server is not created yet' unless @server
    
    @server.use (req, res, next)->
      global.defaultAppVars = {}
      return next()

  parseQueryString: (req, res, next)->
    req.query = qs.parse(req.query)
    return next()

  setControllerPath: (path)->
    @controllerPath = path

  setupRoutes: ()->
    throw new Error 'Server is not created yet' unless @server
    throw new Error 'Controllers Directory path is not set' unless @controllerPath

    fs.readdirSync(@controllerPath).forEach (file) =>
      ControllerClass = require @controllerPath + '/' + file
      contrObj = new ControllerClass()
      contrObj.setupRoutes(@server)

module.exports = AdminAppServer