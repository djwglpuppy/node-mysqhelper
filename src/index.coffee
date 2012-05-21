_ = require("underscore")
async = require("async")
mysql = require("mysql")

client = {}

exports.createClient = (config) ->
    client = exports.client = mysql.createClient(config)

class DBHelper
    constructor: ->
        @client = client
        
    q: (qry, onComplete = ->) ->
        @client.query qry, (err, results, fields) =>
            (throw err; return false) if err
            onComplete(results, fields)
    
    use: (db) -> @client.query "USE #{db}"
    truncate: (table, onComplete = ->) -> @client.query "TRUNCATE TABLE #{table}", onComplete
    onerow: (qry, onComplete) -> @q "#{qry} LIMIT 0,1", (results, fields) -> onComplete(results[0], fields)
    
    get: (args = {}) ->
        _.defaults args,
            table: ""
            id: null
            fields: null
            where: null
            keyById: false
            onerow: false
            orderby: null
            resultsReturn: false
            onComplete: ->
        
        fields = if not args.fields? then "*" else (if _.isArray(args.fields) then args.fields.join(", ") else args.fields)
        
        qry = "SELECT #{fields} FROM #{args.table} "
        
        if args.where? or args.id?
            qry += "WHERE "
            if args.id?
                qry += "id = ?"
                vals = [args.id]
                args.onerow = true
            else
                qrydata = _.map args.where, (data, key) ->
                    if typeof(data) is "object"
                        switch _.keys(data)[0]
                            when "$ne" then "#{key} <> ?"
                    else
                        "#{key} = ?"
                qry += qrydata.join(" AND ")
                
                vals = _.map args.where, (data, key) ->
                    if typeof(data) is "object"
                        _.values(data)[0]
                    else
                        data
        else
            vals = []
        
        qry += " ORDER BY #{args.orderby}" if args.orderby?

        @client.query qry, vals, (err, results, fields) ->
            (throw err; return false) if err
            if args.onerow
                args.onComplete(results[0])
            else if args.keyById
                endResult = {}
                _.each results, (result) ->
                    endResult[" #{result.id} "] = result
                
                args.onComplete(endResult)
            else if args.resultsReturn
                args.onComplete(results)
            else
                args.onComplete(err, results, fields)


    insert: (args = {}) ->
        _.defaults args,
            table: ""
            data: {}
            initUser: false
            replace: false
            onComplete: ->

        if args.initUser
            _.extend args.data,
                create_user: args.initUser
                create_date: @now()
                modify_user: args.initUser
                modify_date: @now()
        
        prefix = if args.replace then "REPLACE" else "INSERT"
        

        qry = "#{prefix} INTO #{args.table} "
        qry += "(" + _.keys(args.data).join(", ") + ")"
        qry += " VALUES (" + _.map(args.data, -> "?").join(", ") + ")"
        @client.query qry, @cleanValues(args.data), (err, info) ->
            newID = if err? then null else info.insertId
            args.onComplete(err, info, newID)


    update: (args = {}) ->
        _.defaults args,
            table: ""
            data: {}
            id: null
            where: {}
            editUser: false
            onComplete: ->
                
        if args.editUser
            _.extend args.data,
                modify_user: args.editUser
                modify_date: @now()
        
        (args.where = {id: args.id}) if args.id?
        
        qry = "UPDATE #{args.table} SET "
        qry += _.map(args.data, (data, key) -> "#{key} = ?").join(", ")
        qry += " WHERE "
        qry += _.map(args.where, (data, key) -> "#{key} = ?").join(" AND ")
        
        vals = @cleanValues(args.data)      
        _.each(_.values(args.where), (value) -> vals.push(value))

        @client.query(qry, vals, args.onComplete)


    deletion: (args = {}, onComplete = ->) ->
        _.defaults args,
            table: ""
            where: {}
            id: null
            onComplete: null
        
        (args.data = {id: args.id}) if args.id?
        onComplete = args.onComplete if args.onComplete?
        
        qry = "DELETE FROM #{args.table} WHERE "
        qry += _.map(args.where, (data, key) -> "#{key} = ?").join(" AND ")
        @client.query(qry, _.values(args.where), onComplete)


    loadExportData: (args = {}) ->
        _.defaults args,
            data: ""
            truncate: yes
            onComplete: ->
        self = @
        async.forEach(args.data, ((data, callback) ->

            loadData = ->
                async.forEach(data.rows, ((rowdata, subcallback) ->
                    _.map rowdata, (row, key) -> delete(rowdata[key]) if not row?
                    self.insert
                        table: data.table
                        data: rowdata
                        onComplete: -> 
                            subcallback()
                ), -> 
                    callback())

            if args.truncate
                self.truncate data.table, -> loadData()
            else 
                loadData()
        ), -> args.onComplete())

    now: -> new Date()
    escapedNow: -> @client.escape(@now())    
    cleanValues: (values) ->
        _.map values, (value) ->
            if typeof value is "string"
                value = value.replace(/\<\s*script.*\>.*\<\s*\/.*script.*\>/gi, '')
            else
                value

exports.DBHelper = DBHelper