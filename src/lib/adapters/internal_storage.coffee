Adapter = require './index'
mongodb = require 'mongodb'
MongoClient = mongodb.MongoClient
ObjectID = mongodb.ObjectID
async = require 'async'

class ISAdapter extends Adapter

  #
  # ## configure
  # configure the db connection arguments
  #
  # @param {object} dbConnArgs, {
  #   user: 'some_user'
  #   password: 'some_pass'
  #   server: 'some_server'
  #   database: 'some_db'
  #   port: 'some_port'
  # }
  configure: (dbConnArgs)->
    @dbConnArgs = dbConnArgs

  #
  # ## getConnection
  # get the connetion object of the mongoDB
  getConnection: (cb)->
    return cb.apply @, [null, global.mongoDBConn] if global.mongoDBConn?

    throw new Error 'Internal Storage DB is not configured yet' unless @dbConnArgs?

    user = @dbConnArgs['user']
    password = @dbConnArgs['password']
    server = @dbConnArgs['server']
    port = @dbConnArgs['port']
    database = @dbConnArgs['database']
    
    MongoClient.connect(
      "mongodb://#{user}:#{password}@#{server}:#{port}/#{database}",
      (e, db)=>
        return cb.apply @, [e] if e?

        global.mongoDBConn = db
        
        db.once 'error', (e)->
          log.error "MongoDB Error: #{e.message}"
          global.mongoDBConn = null

        cb.apply @, [null, db]
    )

  #
  # ## _getInstanceOfObjectId
  # returns instance of Object ID, if valid ID string is provided
  #
  # @param {object}or {string} id
  _getInstanceOfObjectId: (id)->
    if (id? and not(id instanceof ObjectID) and ObjectID.isValid(id))
      return new ObjectID(id)
    else
      return id

  #
  # ## get
  # queries the records from the table(defined in the schema)
  #
  # @param {object} fields, Select fields with [col_name1, col_name2]
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  # @param {object} options, {
  #   sort: {col_name: "ASC|DESC"}
  #   limit: {offset:"idx", count:"noRec"}
  # }
  get: (fields, filters, options, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      filters['_id'] = @_getInstanceOfObjectId(filters['_id']) if filters['_id']?

      collection = db.collection(@getTableName())

      if fields? and fields.length > 0
      then cursor = collection.find(filters, fields)
      else cursor = collection.find(filters)

      if options['sort']?
        for col, order of options['sort']
          if order is 'DESC'
          then options['sort'][col] = -1
          else options['sort'][col] = 1

        cursor.sort(options['sort'])

      if options['limit']?
        cursor.skip(options['limit']['offset']) if options['limit']['offset']?
        cursor.limit(options['limit']['count']) if options['limit']['count']?

      cursor.toArray((e, records)=>
        # db.close()
        cb.apply @, [e, records]
      )

  #
  # ## getOne
  # query the record from the table(defined in the schema)
  #
  # @param {object} fields, Select fields with [col_name1, col_name2]
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  getOne: (fields, filters, options, cb)->
    options = {} unless options?
    options['limit'] = {} unless options['limit']?
    options['limit']['offset'] = 0 unless options['limit']['offset']?
    options['limit']['count'] = 1

    @get fields, filters, options, (e, records)=>
      return cb.apply @, [e, null] if e?

      return cb.apply @, [null, null] unless records?[0]?

      return cb.apply @, [null, records[0]]

  #
  # ## save
  # Updates an existing document or inserts a new document, depending on _id param
  #
  # @param {object} params, Fields with [{col_name1:value1}, {col_name2:value2}]
  save: (params, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      params['_id'] = @_getInstanceOfObjectId(params['_id']) if params['_id']?

      db.collection(@getTableName())
        .save(params, {safe:true, 'new':true}, (e, savedDocs)=>
          # db.close()
          return cb.apply @, [e] if e?

          return cb.apply @, [null, savedDocs['ops'][0]]
        )
  #
  # ## bulksave
  # Bulk Updates an existing document or inserts a new document, depending on _id param
  #
  # @param {object} params, Fields with [{col_name1:value1}, {col_name2:value2}]

  bulkSave: (params, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?
      
      saveParams = (param, loopCb)=>
        param._id = @_getInstanceOfObjectId param._id if param._id?
        @save param, (e)=>
          return loopCb.apply @, [e]
    
      async.each params, saveParams, (err) ->
        return cb.apply @, [err]

  #
  # ## update
  # Updates an existing document
  #
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  # @param {object} params, Fields with [{col_name1:value1}, {col_name2:value2}]
  update: (filters, params, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      filters['_id'] = @_getInstanceOfObjectId(filters['_id']) if filters['_id']?

      db.collection(@getTableName())
        .update(filters, {$set: params}, {safe:true, multi: true}, (e)=>
          # db.close()
          cb.apply @, [e]
        )

  #
  # ## upsert
  # Updates an existing document if match found, else creates new document
  #
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  # @param {object} params, Fields with [{col_name1:value1}, {col_name2:value2}]
  upsert: (filters, params, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      filters['_id'] = @_getInstanceOfObjectId(filters['_id']) if filters['_id']?

      db.collection(@getTableName())
        .update(filters, {$set: params}, {safe:true, upsert: true}, (e)=>
          # db.close()
          cb.apply @, [e]
        )

  #
  # ## delete
  # Delete the matching documents
  #
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  delete: (filters, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      filters['_id'] = @_getInstanceOfObjectId(filters['_id']) if filters['_id']?

      db.collection(@getTableName())
        .remove(filters, (e)=>
          # db.close()
          cb.apply @, [e]
        )

  #
  # ## count
  # Count the matching documents
  #
  # @param {object} filters, Filtering fields with [{col_name: 'value'}]
  count: (filters, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      filters['_id'] = @_getInstanceOfObjectId(filters['_id']) if filters['_id']?
      
      db.collection(@getTableName())
        .count(filters, (e, count)=>
          # db.close()
          cb.apply @, [e, count]
        )

  #
  # ## aggregate
  # Aggregate functions provided by MongoDb
  #
  # @pipes {Array} used for aggregation functions
  aggregate: (pipes, cb)->
    @getConnection (e, db)=>
      return cb(e, null) if e?

      db.collection(@getTableName())
        .aggregate(pipes, (e, records)=>
          # db.close()
          cb.apply @, [e, records]
        )

module.exports = ISAdapter