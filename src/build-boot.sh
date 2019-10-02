#!/bin/bash

set -Ceu

boot_type=$1

if [ "$boot_type" = "single" ]; then
    tool_parent_dir=$2
fi

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

exec bash \$MULANG_SOURCE_DIR/main.sh "\$@"

#SOURCE_IMAGE
EOF

    cat var/packed-image.sh | gzip -n -c

elif [ "$boot_type" = "devel" ]; then

    pwd=$(pwd)

    cat <<EOF
#!/bin/bash

export MULANG_SOURCE_DIR=$pwd/var/devel-target

exec bash \$MULANG_SOURCE_DIR/main.sh "\$@"

EOF

fi
