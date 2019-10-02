
build: mulang

mulang: var/single-3 var/single-4
	cmp -s var/single-2 var/single-3
	cmp -s var/single-2 var/single-4
	cp var/single-4 $@

var/dir-single-1/var/single-out: FORCE
	@if [ ! -e var/dir-single-1 ]; then mkdir -p var/dir-single-1; ln -s ../../src var/dir-single-1/src; fi
	@cd var/dir-single-1; MULANG_SOURCE_DIR=../../src bash ../../src/main.sh single

var/single-1: var/dir-single-1/var/single-out
	cp -p var/dir-single-1/var/single-out $@
	cp -p var/dir-single-1/var/packed-image.sh var/packed-image-1.sh

var/dir-single-2/var/single-out: var/single-1
	@if [ ! -e var/dir-single-2 ]; then mkdir -p var/dir-single-2; ln -s ../../src var/dir-single-2/src; fi
	@cd var/dir-single-2; ../single-1 single

var/single-2: var/dir-single-2/var/single-out
	cp -p var/dir-single-2/var/single-out $@
	cp -p var/dir-single-2/var/packed-image.sh var/packed-image-2.sh

var/dir-single-3/var/single-out: var/single-2
	@if [ ! -e var/dir-single-3 ]; then mkdir -p var/dir-single-3; ln -s ../../src var/dir-single-3/src; fi
	@cd var/dir-single-3; ../single-2 single

var/single-3: var/dir-single-3/var/single-out
	cp -p var/dir-single-3/var/single-out $@
	cp -p var/dir-single-3/var/packed-image.sh var/packed-image-3.sh

var/dir-devel-1/var/devel-out: var/single-3
	@if [ ! -e var/dir-devel-1 ]; then mkdir -p var/dir-devel-1; ln -s ../../src var/dir-devel-1/src; fi
	@cd var/dir-devel-1; ../single-3 devel

var/devel-1: var/dir-devel-1/var/devel-out
	cp -p var/dir-devel-1/var/devel-out $@

var/dir-single-4/var/single-out: var/devel-1
	@if [ ! -e var/dir-single-4 ]; then mkdir -p var/dir-single-4; ln -s ../../src var/dir-single-4/src; fi
	@cd var/dir-single-4; ../devel-1 single

var/single-4: var/dir-single-4/var/single-out
	cp -p var/dir-single-4/var/single-out $@
	cp -p var/dir-single-4/var/packed-image.sh var/packed-image-4.sh

test: FORCE mulang
	cd test/1; rm -rf var
	cd test/1; ../../mulang
	./test/1/var/single-out > test/1/var/result.txt
	diff -u test/1/etc/expected.txt test/1/var/result.txt
	@echo OK

FORCE:

