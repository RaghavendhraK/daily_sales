Controller = require '../controller'
StaffModel = require '../../models/internal_storage/staffs'
Constant = require '../../helpers/constant'

_ = require 'underscore'
moment = require 'moment'

class StaffsController extends Controller
  constructor: ()->
    super()
    @staffModel = new StaffModel

  setupRoutes: (server)=>
    server.get('/staffs', @checkAuthentication, @index)
    server.get('/add-staff', @checkAuthentication, @renderAddStaff)
    server.post('/add-staff', @checkAuthentication, @addStaff)
    server.get('/edit-staff/:staffId', @checkAuthentication, @renderEditStaff)
    server.post('/edit-staff/:staffId', @checkAuthentication, @editStaff)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Staffs'
    }

    @staffModel.getAllStaffs (e, staffs)=>
      return next(e) if e?

      renderValues['staffs'] = @_formatStaffs staffs

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(renderValues)

      res.render('staffs/index', renderValues)

  _formatStaffs: (staffs)->
    _.each staffs, (staff)->
      staffType = _.findWhere Constant.STAFF_TYPES, {key: staff['staff_type']}
      staff['staff_type'] = staffType?['value']

    return staffs

  renderAddStaff: (req, res, next)=>
    renderValues = {
      page_title: 'Staffs :: Add'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['staff'] = req.body

    @_renderAddEdit req, res, renderValues

  renderEditStaff: (req, res, next)=>
    renderValues = {
      page_title: 'Staffs :: Edit'
    }

    #while showing the error message
    unless _.isEmpty(req.body)
      renderValues['staff'] = req.body
      renderValues['staff']['_id'] = req.params.staffId
      return @_renderAddEdit req, res, renderValues

    @staffModel.getById req.params.staffId, (e, staff)=>
      return next(e) if e?

      renderValues['staff'] = staff
      @_renderAddEdit req, res, renderValues

  _renderAddEdit: (req, res, renderValues)->
    renderValues['staff_types'] = @setSelectedMustacheDropdownValues Constant.STAFF_TYPES, 'key', renderValues['staff']?['staff_type']
    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(renderValues)
    res.render('staffs/add-edit', renderValues)

  addStaff: (req, res, next)=>
    @staffModel.create req.body, (e)=>
      console.log e
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStaff req, res, next
      else
        staff_name = req.body.staff_name
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.STAFF_ADDED_SUCCESSFULLY
        }
        req.flash 'flash_messages', message
        return res.redirect('/staffs')

  editStaff: (req, res, next)=>
    staffId = req.params['staffId']
    
    @staffModel.updateById staffId, req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStaff req, res, next
      else
        staff_name = req.body.staff_name
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.STAFF_ADDED_SUCCESSFULLY
        }
        req.flash 'flash_messages', message
        return res.redirect('/staffs')

module.exports = StaffsController