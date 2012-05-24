should = require("should")
db = require("../src")
tester = {}
returndata = {}

describe "Data Insertion", ->
    before (done) ->
        db.createClient
            host: "localhost"
            database: "testmysql"
            user: "root"
            password: ""

        tester = new db.DBHelper()
        tester.truncate "simpletest", -> done()

    beforeEach (done) ->
        tester.truncate "simpletest", -> done()

    describe "Simple Insertion", ->

        before (done) ->
            returndata = {}
            tester.insert        
                table: "simpletest"
                data: {field: "Test Field"}
                onComplete: ->
                    returndata = arguments
                    done()

        it "should not return an error", ->
            should.not.exist returndata[0]

        it "should return database info", ->
            returndata[1].should.be.a('object')

        it "should return an insert id", ->
            returndata[2].should.eql(1)

    describe "Script Insertion", ->

        it "should insert script data by default", (done) ->
            tester.insert        
                table: "simpletest"
                data: {field: "<script>console.log('hello');</script>"}
                onComplete: ->
                    tester.get
                        table: "simpletest"
                        id: 1
                        onComplete: (data) ->
                            data.field.should.match /script/
                            done()

        it "should not allow scripts with a method toggle", (done) ->
            tester.insert        
                table: "simpletest"
                data: {field: "<script>console.log('hello');</script>"}
                cleanValues: true
                onComplete: ->
                    tester.get
                        table: "simpletest"
                        id: 1
                        onComplete: (data) ->
                            data.field.should.not.match /script/
                            done()

        it "should not allow scripts with a root override", (done) ->
            tester.completeCleaner = true

            tester.insert        
                table: "simpletest"
                data: {field: "<script>console.log('hello');</script>"}
                onComplete: ->
                    tester.get
                        table: "simpletest"
                        id: 1
                        onComplete: (data) ->
                            data.field.should.not.match /script/
                            done()   

        it "should allow scripts with an instance override", (done) ->
            tester.completeCleaner = true

            tester.insert        
                table: "simpletest"
                data: {field: "<script>console.log('hello');</script>"}
                cleanValues: false
                onComplete: ->
                    tester.get
                        table: "simpletest"
                        id: 1
                        onComplete: (data) ->
                            data.field.should.match /script/
                            done()   








