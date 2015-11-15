_ = require 'underscore'

class Model
  constructor: ()->

  #
  # ## getSchema
  # returns the schema of the table
  getSchema: ()->
    throw new Error 'getSchema method is not defined in subclass'

  getTableName: ()->
    schema = @getSchema()
    throw new Error 'Table name is not mentioned in the schema' unless schema.table?
    return schema.table

  getFields: ()->
    schema = @getSchema()
    throw new Error 'Fields are not mentioned in the schema' unless (schema.fields? and schema.fields instanceof Object)
    return Object.keys(schema.fields)

  getIdFieldName: ()->
    schema = @getSchema()
    throw new Error 'Id Field name is not mentioned in the schema' unless schema.id?
    return schema.id

  getFilterWithId: (id)->
    filter = {}
    filter[@getIdFieldName()] = id
    return filter

  getDataAdapter: ()->
    throw new Error 'getDataAdapter method is not defined in subclass'

  getByFilters: (filters, args..., cb)->
    fields = []
    options = {}
    if args?.length > 0
      if args[0] instanceof Array
        fields = args[0]
        options = args[1] if args[1]? and args[1] instanceof Object
      else if args[0] instanceof Object
        options = args[0]

    @getDataAdapter().get fields, filters, options, (e, results)=>
      return cb.apply @, [e, results]

  getOne: (filters, args..., cb)->
    fields = []
    if args?.length > 0
      if args[0] instanceof Array
        fields = args[0]

    @getDataAdapter().getOne fields, filters, (e, record)=>
      return cb.apply @, [e, record]

  getById: (id, cb)->
    filter = @getFilterWithId(id)
    @getOne filter, (e, result)=>
      return cb.apply @, [e] if e?
      e = @getErrorObject(CONFIGURED_MESSAGES.DOES_NOT_EXIST, "id", id) unless result?
      return cb.apply @, [e, result]

  getAll: (cb)->
    filter = {}
    @getByFilters filter, (e, result)=>
      return cb.apply @, [e, result]

  getN: (n, cb)->
    filters = {}
    options = if typeof(n) is 'number' then {limit: {count: n}} else {}
    options['sort'] = {created_dt: 'DESC'}
    @getByFilters filters, options, (e, result)=>
      return cb.apply @, [e, result]

  create: (params, cb)->
    date = new Date
    params['created_dt'] = date
    params['updated_dt'] = date

    params = @getOnlySchemaFields(params)
    @getDataAdapter().save params, (e, result)=>
      return cb.apply @, [e, result]

  update: (filters, params, cb)->
    params['updated_dt'] = new Date

    params = @getOnlySchemaFields(params)
    console.log params

    @getDataAdapter().update filters, params, (e)=>
      return cb.apply @, [e]

  upsert: (filters, params, cb)->
    params['updated_dt'] = new Date

    params = @getOnlySchemaFields(params)
    @getDataAdapter().upsert filters, params, (e)=>
      return cb.apply @, [e]

  updateById: (id, params, cb)->
    @isRecordWithIdExists id, (e)=>
      return cb.apply @, [e] if e?

      filter = @getFilterWithId(id)
      @update filter, params, (e)=>
        return cb.apply @, [e]

  delete: (filters, cb)->
    @getDataAdapter().delete filters, (e)=>
      return cb.apply @, [e]

  bulkSave: (params, cb)->
    params = @getOnlySchemaFields(params)
    @getDataAdapter().bulkSave params, (e)=>
      return cb.apply @, [e]

  deleteById: (id, cb)->
    @isRecordWithIdExists id, (e)=>
      return cb.apply @, [e] if e?

      filter = @getFilterWithId(id)
      @delete filter, cb

  count: (filters, cb)->
    @getDataAdapter().count filters, (e, count)=>
      return cb.apply @, [e, count]

  isRecordWithIdExists: (id, cb)->
    filter = @getFilterWithId(id)
    @count filter, (e, count)=>
      return cb.apply @, [e] if e?

      return cb.apply @, [null] if count > 0

      e = new Error("Record with id #{id} not found")
      return cb.apply @, [e]

  getOnlySchemaFields: (params)->
    fields = @getFields()
    fields.push @getIdFieldName()

    isParamsArray = true
    unless _.isArray(params)
      params = [params]
      isParamsArray = false

    params = _.map params, (param)->
      temp = {}
      _.each param, (value, key)->
        if _.contains fields, key
          temp[key] = value
      return temp

    unless isParamsArray
      params = params[0]

    return params

module.exports = Model