## MysqlHELPER

A Class Created in CoffeeScript that makes working with felixge's [node-mysql] (https://github.com/felixge/node-mysql) a little easier (I think / hope)

To get the most out of this module, I highly recommend you use it in conjunction with CoffeeScript (especially for extending classes)

### Installation

```
npm install mysqlhelper
```

### Usage

```coffeescript
db = require("mysqlhelper")

#Open the connection to the Mysql Database
db.createClient
	host: "localhost"
	database: "etymdb"
	user: "root"
	password: ""

#Create a helper object
helper = new db.DBHelper()

helper.get
	table: "users"
	onComplete: -> console.log arguments

```

Documentation will follow shortly... thanks for your patience

### createClient()

### DBHelper Class

#### @client

#### @q

#### @use

#### @truncate

#### @onerow

#### @get

#### @insert

#### @update

#### @deletion

#### @now

#### @escapedNow

#### @cleanValues



