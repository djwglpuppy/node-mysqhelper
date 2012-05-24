# MySqlHELPER

A class created in CoffeeScript that makes working with felixge's [node-mysql] (https://github.com/felixge/node-mysql) a little easier (I think / hope)

To get the most out of this module, I highly recommend you use it in conjunction with CoffeeScript (especially for extending classes).  This module will still work fine with Regular JS. 


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

#API

Documentation is a work in progress.... Thanks so much for your patience.

### createClient([options])

Creates the mysql client instance.  The `options` are the exact same as the `mysql` module.

## DBHelper Class & Methods

#### Constructor

Holds a series of methods to make working with `node-mysql` a little quicker.  I use this class primary to build other classes with CoffeeScript.

*New Instance Usage:*

```coffeescript
helper = new db.DBHelper()

helper.get
	table: "users"
	id: 1
	onerow: true
	onComplete: -> console.log "Hello number 1 user", arguments
```

*Class Extension Usage (recommended):*

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

## DBHelper Public Properties
- **client (obj)** :The reference to the mysql client created with `createClient`.  This is an instance of the `node-mysql` object.  Every client method found at [node-mysql] (https://github.com/felixge/node-mysql) can be used here

- **completeCleaner (bool)** : This is a public object property that can be set to TRUE to make sure that no SCRIPT tags get inserted / updated into the tables
<br />*(defaults to false)*

## DBHelper Public Methods

#### @insert(params)

Insert Data Into a Table

**params**

- **table (string)** : the table to insert data into
*<i>(required)*

- **data (obj)** : data to insert into the table
<br />*(required)*

This will be entered in a `{field: value}` format

```javascript
{
	name: "David Roberts",
	age: 34,
	hasdog: true
}
```

- **replace (bool)** : Use a REPLACE statement instead of INSERT
<br />*(defaults to false)*

- **cleanValues (bool)** : This will override the `completeCleaner` public property to allow (or not allow) script tags
<br />*(defaults to NULL by default, but if you set it to TRUE or FALSE it will take precedence)*

- **onComplete(cb(err, dbinfo, insertid))** : The callBack once the operation has been performed
<br />*(optional (though recommended))*
	- cb args:
		- **err** : error information sent back from mysql library
		- **dbinfo** : database information sent back from mysqllibrary
		- **insertid** : **NEW!** the insert id of the record inserted

Usage:

```coffeescript
dbHelper.get
	table: "products"
	data: 
		title: "shoe"
		description: "so comfy"
		qty: 25
	cleanValues: true
	onComplete: (err, dbinfo, insertid) ->
		console.log "Inserted New Product: #{insertid}"
```

#### @q(query, cb)

#### @onerow(query, cb)

#### @get(params)

Retrieve data from a specified mysqlsql table

**params**

- **table (string)** : the table to query (**required**)
- **id (number)** : the id of the table (table has to have an id field) (this will override the **onerow** param to `true`)
- **fields (array)** : A list of fields to return in the query (returns all by default)
- **where (object)** : field / value of how you want to filter your result set (**required**)
- **keyById (bool)** : return result as an object keyed by the `id` field of the table (false by default)
- **onerow (bool)** : return only the first row (false by default)
- **orderby (string)** : order query by specific field in the string (ex/ "name ASC")
- **resultsReturn (bool)** : only return the results instead of the error and fields in the callback
- **onComplete (callback)** : callback once the query is complete (**required**)

*Usage:*

```coffeescript
#Grabbing a group of Products
dbHelper.get
	table: "products"
	fields: ["id", "title", "description", "qty"]
	where: {type: "clothing", in_stock: true}
	orderby: "title ASC"
	resultsReturn: true
	onComplete: (products) ->
		console.log products


#Grabbing a single Product
dbHelper.get
	table: "products"
	id: productID
	onComplete: (product) ->
		console.log product
```

#### @update(params)

#### @deletion(params)

#### @now()

#### @escapedNow()

#### @cleanValues(values)

#### @use(database)

####@getMultipleTables(params)

#### @truncate(table, cb)
