.PHONY: test
	
all: lib/index.js

lib/index.js: src/index.coffee
	coffee --bare --output lib/ src/

test:
	mocha -R spec --compilers coffee:coffee-script

