Controller = require '../controller'
path = require 'path'
moment = require 'moment'

class ExportController extends Controller
  constructor: ()->
    super()

  setupRoutes: (server)=>
    server.get('/export', @index)

  index: (req, res, next)->
    if req.session['from_date']?
      fromDate = moment(req.session['from_date'], 'DD/MM/YYYY')
      toDate = moment(req.session['to_date'], 'DD/MM/YYYY')
    else
      fromDate = moment().startOf('month')
      toDate = moment()

    params = {
      from_date: fromDate.format('YYYY-MM-DD')
      to_date: toDate.format('YYYY-MM-DD')
    }

    excelFilePath = path.resolve(config.get('excel_dir_path'), 'sample.xlsx')

    return res.download(excelFilePath, 'sample1.xlsx')

module.exports = ExportController