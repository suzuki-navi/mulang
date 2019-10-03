#!/bin/bash

set -Ceu

########################################

option=

while [ "$#" != 0 ]; do
    case "$1" in
        --use-hard )
            option="$option --use-hard"
            ;;
        --use-soft )
            option="$option --use-soft"
            ;;
        * )
            ;;
    esac
    shift
done

########################################

if [ ! -e var ]; then
    mkdir var
    echo "*" > var/.gitignore
fi

########################################
# ソースファイルの一覧

target_sources=$(ls src)

target_sources_files_hash=$(for f in $target_sources; do
    echo $f
done | sha1sum | cut -b-40)

target_sources_hash=$((echo $target_sources_files_hash; cat $(echo $(for f in $target_sources; do echo $f | sed "s#^#src/#"; done))) | sha1sum | cut -b-40)

rm_targets=$(echo $(echo .dir; for f in $target_sources; do echo $f; done))

########################################
#

cat <<EOF
single: var/single-out

devel: var/devel-out

EOF

cat <<EOF
var/single-out: var/packed-image.sh
	bash $MULANG_SOURCE_DIR/build-boot.sh $option single \\\$\$HOME/.xsvutils > \$@.tmp
	chmod +x \$@.tmp
	mv \$@.tmp \$@

var/packed-image.sh: var/single-target-files
	(cd var/single-target; perl $MULANG_SOURCE_DIR/pack-dir.pl) > var/packed-image.sh

var/devel-out: var/devel-target-files
	bash $MULANG_SOURCE_DIR/build-boot.sh $option devel > \$@.tmp
	chmod +x \$@.tmp
	mv \$@.tmp \$@

EOF

if [ ! -e var/target_sources_files_hash -o "$(cat var/sources-files-hash 2>/dev/null)" != $target_sources_files_hash ]; then
    echo $target_sources_files_hash >| var/sources-files-hash
    for buildtype in single devel; do
        if [ -e var/$buildtype-target ]; then (
            cd var/$buildtype-target
            bash $MULANG_SOURCE_DIR/rm-targets.sh $rm_targets
            true
        ) fi
    done
fi
if [ ! -e var/target_sources_hash -o "$(cat var/sources-hash 2>/dev/null)" != $target_sources_hash ]; then
    echo $target_sources_hash >| var/sources-hash
fi

for buildtype in single devel; do
    cat <<EOF
var/$buildtype-target-files: $(echo $(for f in $target_sources; do echo $f | sed "s#^#var/$buildtype-target/#"; done))
	touch var/$buildtype-target-files

EOF

    for f in $target_sources; do
        cat <<EOF
var/$buildtype-target/$f: src/$f var/$buildtype-target/.dir
	cp src/$f var/$buildtype-target/$f

EOF
    done
done

for buildtype in single devel; do
    cat <<EOF
var/$buildtype-target/.dir:
	mkdir -p var/$buildtype-target
	touch var/$buildtype-target/.dir

EOF
done

cat <<EOF
var/target/.dir:
	mkdir -p var/target
	touch var/target/.dir

EOF


cat <<EOF
FORCE:

EOF

