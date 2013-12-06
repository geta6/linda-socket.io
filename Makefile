build:
	./node_modules/.bin/coffee -b -c -o lib src

watch:
	./node_modules/.bin/coffee -w -b -c -o lib src
