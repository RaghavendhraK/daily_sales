Controller = require '../controller'
StaffModel = require '../../models/internal_storage/staffs'
Constant = require '../../helpers/constant'

_ = require 'underscore'
moment = require 'moment'
util = require 'util'

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
    server.get('/delete-staff/:staffId', @checkAuthentication, @deleteStaff)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Staffs'
    }

    @staffModel.getAllStaffs (e, staffs)=>
      return next(e) if e?

      renderValues['staffs'] = @_formatStaffs staffs

      # renderValues['csrf_token'] = req.csrfToken()
      renderValues = @mergeDefRenderValues(req, renderValues)
      res.render('staffs/index', renderValues)

  _formatStaffs: (staffs)->
    _.each staffs, (staff)->
      staffType = _.findWhere Constant.STAFF_TYPES, {key: staff['staff_type']}
      staff['staff_type'] = staffType?['value']
      staff['doj'] = moment(staff['doj'], 'YYYY-MM-DD').format('DD/MM/YYYY')

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

      staff['doj'] = moment(staff['doj'], 'YYYY-MM-DD').format('DD/MM/YYYY')

      renderValues['staff'] = staff
      @_renderAddEdit req, res, renderValues

  _renderAddEdit: (req, res, renderValues)->
    renderValues['staff_types'] = @setSelectedMustacheDropdownValues(
      Constant.STAFF_TYPES,
      'key',
      renderValues['staff']?['staff_type']
    )
    # renderValues['csrf_token'] = req.csrfToken()
    renderValues = @mergeDefRenderValues(req, renderValues)
    res.render('staffs/add-edit', renderValues)

  addStaff: (req, res, next)=>
    if req['body']?['doj']?
      req.body['doj'] = moment(req.body['doj'], 'DD/MM/YYYY')
                          .format('YYYY-MM-DD')
    
    @staffModel.create req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStaff req, res, next
      else
        staffName = req.body.staff_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.STAFF_ADDED_SUCCESSFULLY, staffName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/staffs')

  editStaff: (req, res, next)=>
    staffId = req.params['staffId']
    req.body['doj'] = moment(req.body['doj'], 'DD/MM/YYYY').format('YYYY-MM-DD')

    @staffModel.updateById staffId, req.body, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
        req.flash 'flash_messages', message
        return @renderAddStaff req, res, next
      else
        staffName = req.body.staff_name
        message = {
          type: 'success'
          message: util.format(CONFIGURED_MESSAGES.STAFF_EDITED_SUCCESSFULLY, staffName)
        }
        req.flash 'flash_messages', message
        return res.redirect('/staffs')

  deleteStaff: (req, res, next)=>
    staffId = req.params['staffId']

    @staffModel.deleteById staffId, (e)=>
      if e?
        message = {
          type: 'error'
          message: e.message
        }
      else
        message = {
          type: 'success'
          message: CONFIGURED_MESSAGES.STAFF_DELETED_SUCCESSFULLY
        }
      req.flash 'flash_messages', message
      return res.redirect('/staffs')

module.exports = StaffsController