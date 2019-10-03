#!/bin/bash

set -Ceu

boot_type=
use_hard=
use_soft=
tool_parent_dir=

while [ "$#" != 0 ]; do
    case "$1" in
        --use-hard )
            use_hard=1
            ;;
        --use-soft )
            use_soft=1
            ;;
        * )
            if [ "$boot_type" = "single" ]; then
                tool_parent_dir=$1
            else
                boot_type=$1
            fi
            ;;
    esac
    shift
done


if [ "$boot_type" = "single" ]; then

    version_hash=$(cat var/sources-hash)
    target_mulang_source_dir=$tool_parent_dir/version-$version_hash

    cat <<EOF
#!/bin/bash

tool_parent_dir=$tool_parent_dir
export MULANG_SOURCE_DIR=\$tool_parent_dir/version-$version_hash

if [ ! -e \$MULANG_SOURCE_DIR/.dir ]; then
    if [ ! -e \$tool_parent_dir ]; then
        mkdir -p \$tool_parent_dir
    fi

    mkdir \$MULANG_SOURCE_DIR.tmp 2>/dev/null
    cat \$0 | (
        cd \$MULANG_SOURCE_DIR.tmp || exit \$?
        perl -ne 'print \$_ if \$f; \$f=1 if /^#SOURCE_IMAGE\$/' | gzip -n -d -c | bash
    )
    if [ -e \$MULANG_SOURCE_DIR ]; then
        rm -rf \$MULANG_SOURCE_DIR
    fi
    mv \$MULANG_SOURCE_DIR.tmp \$MULANG_SOURCE_DIR
fi

if [ ! -e \$MULANG_SOURCE_DIR ]; then
    echo "Not found: \$MULANG_SOURCE_DIR" >&2
    exit 1;
fi

EOF

    finally_rm_target=

    if [ -n "$use_soft" ]; then
        cat <<\EOF
if [ -z "$UID" ]; then
    UID=$(id -u)
fi
if [ -d /run/user/$UID ]; then
    export MULANG_SOFT_WORKING_DIR=$(mktemp -d /run/user/$UID/mulang-XXXXXXXX)
elif [ -d /dev/shm ]; then
    export MULANG_SOFT_WORKING_DIR=$(mktemp -d /dev/shm/mulang-XXXXXXXX)
else
    export MULANG_SOFT_WORKING_DIR=$(mktemp -d /tmp/mulang-XXXXXXXX)
fi
[ -n "$MULANG_SOFT_WORKING_DIR" ] || { echo "Cannot create MULANG_SOFT_WORKING_DIR: $MULANG_SOFT_WORKING_DIR"; exit $?; }

EOF
        finally_rm_target="$finally_rm_target \"\$MULANG_SOFT_WORKING_DIR\""
    fi
    if [ -n "$use_hard" ]; then
        cat <<\EOF
export MULANG_HARD_WORKING_DIR=$(mktemp -d /tmp/mulang-hard-XXXXXXXX)
[ -n "$MULANG_HARD_WORKING_DIR" ] || { echo "Cannot create MULANG_HARD_WORKING_DIR: $MULANG_HARD_WORKING_DIR"; exit $?; }

EOF
        finally_rm_target="$finally_rm_target \"\$MULANG_HARD_WORKING_DIR\""
    fi

    if [ -n "$finally_rm_target" ]; then
        cat <<EOF
trap "rm -rf $finally_rm_target" EXIT

EOF
    fi

    cat <<EOF
exec bash \$MULANG_SOURCE_DIR/main.sh "\$@"

#SOURCE_IMAGE
EOF

    cat var/packed-image.sh | gzip -n -c

elif [ "$boot_type" = "devel" ]; then

    pwd=$(pwd)

    cat <<EOF
#!/bin/bash

export MULANG_SOURCE_DIR=$pwd/var/devel-target

EOF

    if [ -n "$use_hard" ]; then
        cat <<EOF
export MULANG_HARD_WORKING_DIR="$pwd/var/devel-hard-working-dir"
rm -rf \$MULANG_HARD_WORKING_DIR
mkdir -p \$MULANG_HARD_WORKING_DIR

EOF
    fi
    if [ -n "$use_soft" ]; then
        cat <<EOF
export MULANG_SOFT_WORKING_DIR="$pwd/var/devel-soft-working-dir"
rm -rf \$MULANG_SOFT_WORKING_DIR
mkdir -p \$MULANG_SOFT_WORKING_DIR

EOF
    fi

    cat <<EOF
exec bash \$MULANG_SOURCE_DIR/main.sh "\$@"

EOF

fi
