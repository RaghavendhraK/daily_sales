class Adapter

  constructor: (options)->
    @configure(options) if options?

  configure: (options)->
    @options = options

  setSchema: (schema)->
    @schema = schema

  getSchema: ()->
    throw new Error 'Schema is not defined' unless @schema?
    return @schema

  getTableName: ()->
    schema = @getSchema()
    throw new Error 'Table name is not mentioned in the schema' unless schema.table?
    return schema.table

  getFields: ()->
    schema = @getSchema()
    throw new Error 'Fields are not mentioned in the schema' unless (schema.fields? and schema.fields instanceof Object)
    return schema.fields

  getIdFieldName: ()->
    schema = @getSchema()
    throw new Error 'Id Field name is not mentioned in the schema' unless schema.id?
    return schema.id

  getConnection: (connectionArgs..., cb)->
    throw new Error 'getConnection method is not defined in subclass'

  get: (fields, filters, options, cb)->
    throw new Error 'get method is not defined in subclass'

  getOne: (fields, filter, cb)->
    throw new Error 'getOne method is not defined in subclass'

  save: (saveArgs..., cb)->
    throw new Error 'save method is not defined in subclass'

  update: (updateArgs..., cb)->
    throw new Error 'update method is not defined in subclass'

  delete: (delArgs..., cb)->
    throw new Error 'delete method is not defined in subclass'

  count: (countArgs..., cb)->
    throw new Error 'count method is not defined in subclass'

  close: (cb)->
    throw new Error 'close method is not defined in subclass'

module.exports = Adapter