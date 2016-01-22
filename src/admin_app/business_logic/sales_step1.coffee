StaffModel = require '../../models/internal_storage/staffs'

class SalesStep1BL

  constructor: ()->
    @staffModel = new StaffModel

  getCashiers: (cb)->
    @staffModel.getCashiers (e, cashiers)->
      return cb.apply @, [e, cashiers]


module.exports = SalesStep1BL