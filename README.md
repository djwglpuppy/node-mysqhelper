# MySqlHELPER

A Class Created in CoffeeScript that makes working with felixge's [node-mysql] (https://github.com/felixge/node-mysql) a little easier (I think / hope)

To get the most out of this module, I highly recommend you use it in conjunction with CoffeeScript (especially for extending classes)

##Installation

```
npm install mysqlhelper
```

## Simple Usage

```coffeescript
db = require("mysqlhelper")

#Open the connection to the Mysql Database
db.createClient
	host: "localhost"
	database: "database"
	user: "root"
	password: ""

#Create a helper object
helper = new db.DBHelper()

helper.get
	table: "users"
	onComplete: -> console.log arguments

```

##API Guide

Documentation is a work in progress.... Thanks so much for your patience.

### createClient([options])

Creates the mysql client instance.  The `options` are the exact same as the `mysql` module.

### DBHelper Class & Methods

#### DBHelper Class

Holds a series of methods to make working with `node-mysql` a little quicker.  I use this class primary to build other classes with CoffeeScript.

<i>Example of creating a new instance</i>

```coffeescript
helper = new db.DBHelper()

helper.get
	table: "users"
	id: 1
	onerow: true
	onComplete: -> console.log "Hello number 1 user", arguments
```

<i>Example of extending the class to organize data (preferred)</i>

```coffeescript

class Users extends db.DBHelper

	getByID: (id, onComplete) ->
		@get
			table: "users"
			id: id
			onerow: true
			onComplete: onComplete

users = new Users()

users.getByID 1, -> console.log "Hello number 1 user", arguments
```


#### @client

The reference to the mysql client created with `createClient`.  This is an instance of the `node-mysql` object.  Every client method found at [node-mysql] (https://github.com/felixge/node-mysql) can be used here

#### @q(query, cb)

#### @onerow(query, cb)

#### @get(params)

#### @insert(params)

#### @update(params)

#### @deletion(params)

#### @now()

#### @escapedNow()

#### @cleanValues(values)

#### @use(database)

#### @truncate(table, cb)
