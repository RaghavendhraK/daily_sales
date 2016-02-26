LoginModel = require '../models/internal_storage/login'
AuditLogModel = require '../models/internal_storage/audit_log'

csrf = require 'csurf'
titleCase = require 'title-case'
_ = require 'underscore'

class AdminAppController
  
  constructor: ()->
    @loginModel = new LoginModel()
    @auditLogModel = new AuditLogModel()

  getMustacheDefaultValues: ()->
    unless @defaultRenderValues?
      @defaultRenderValues = {
        'static_url': '/static'
      }
    return @defaultRenderValues

  mergeDefRenderValues: (req, values)->
    renderValues = {}
    _.extend(renderValues, @getMustacheDefaultValues(), values)
    renderValues['flash_message'] = @getFlashMessages req
    return renderValues

  _onLoginPage: (req, res, next)->
    req.session.logged_in_user = null
    #if it is a login page, then go ahead with the login page
    return next() if req.path is '/login' and next?
    req.session.redirect_to = req.path unless req.method is 'POST'
    res.redirect('/login')

  checkAuthentication: (req, res, next)=>
    if req.session.logged_in_user?
      @loginModel.isUserAuthenticated(
        req.session.logged_in_user.auth_token,
        (e, userDetails)=>
          return next() if userDetails?
          req.flash('error_message', CONFIGURED_MESSAGES.USER_LOGGED_IN_DIFF_MACHINE)
          @_onLoginPage(req, res, next)
      )
    else
      @_onLoginPage(req, res, next)

  auditLog: (req, res, next)=>
    res.on 'finish', ()=>
      #To Do: send the correct data to log
      @auditLogModel.log req, res, ->
    return next()
  
  checkCSRFToken: (req, res, next)->
    csrf({ ignoreMethods: [] })(req, res, next)

  setSelectedMustacheDropdownValues: (list, keyToCheck, valueToCheck)->
    for key, value of list
      value['selected'] = (value[keyToCheck]? and valueToCheck?) and (value[keyToCheck].toString() is valueToCheck.toString())
    return list

  getFlashMessages: (req)->
    retValue = {}

    flashMsgs = req.flash 'flash_messages'

    for msg in flashMsgs
      type = msg['type']
      retValue[type] = [] unless retValue[type]?

      messages = []
      if type is 'error' and msg?['errors']?
        messages.push msg['message'] if msg['message']?
        for error in msg['errors']
          formattedMsg = ''
          if error['message']?
            if error['property']?
              fieldName = error['property'].split('.').pop()
              formattedMsg += titleCase(fieldName) + ' '
            formattedMsg += error['message']
          else
            formattedMsg = error

          messages.push formattedMsg
      else
        messages.push msg?.message

      retValue[type].push {message: messages}

    return retValue
  
module.exports = AdminAppController