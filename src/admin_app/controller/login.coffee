Controller = require '../controller'
LoginModel = require '../../models/internal_storage/login'
Is = require 'is_js'

class LoginController extends Controller
  constructor: () ->
    super()
    @loginModel = new LoginModel
  
  setupRoutes: (server) ->
    server.get('/login', @checkAuthentication, @index)
    server.post('/login', @doLogin)
    server.get('/logout', @doLogout)

  index: (req, res, next)=>
    #If already logged in, redirect to dashboard page
    if req.session.logged_in_user?
      res.redirect('/dashboard')
      return

    renderValues = {
      page_title: 'Login'
    }

    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(renderValues)
    res.render('login', renderValues)

  doLogin: (req, res, next)=>
    username = req.body.username
    password = req.body.password
    return @_renderLoginFail(req, res, next) if Is.any.empty(username, password)

    @loginModel.login username, password, (e, userDetails)=>
      throw e if e?

      return @_renderLoginFail(req, res, next) unless userDetails?

      req.session.logged_in_user = userDetails
      if req.session.redirect_to?.length > 0
        #Redirect to the originally requested pag2929e
      then res.redirect(req.session.redirect_to)
      else res.redirect('/dashboard')

  _renderLoginFail: (req, res, next)->
    renderValues = {
      page_title: 'Login'
      email_address: req.body.email_address
    }

    req.flash 'error', {message: CONFIGURED_MESSAGES.LOGIN_FAIL}
    renderValues['flash_message'] = @getFlashMessages(req)

    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(renderValues)

    return res.render('login', renderValues)

  doLogout: (req, res, next)=>
    if req.session.logged_in_user?
      @loginModel.logout req.session.logged_in_user['auth_token'], (e)->
        throw e if e?
        req.session.destroy(
          res.redirect('/login')
        )
    else
      req.session.destroy(
        res.redirect('/login')
      )

module.exports = LoginController