#!/bin/bash

set -Ceu
# -C リダイレクトでファイルを上書きしない
# -e コマンドの終了コードが1つでも0以外になったら直ちに終了する
# -u 設定されていない変数が参照されたらエラー

target=

while [ "$#" != 0 ]; do
    case "$1" in
        * )
            target=$1
            ;;
    esac
    shift
done

export MULANG_SOURCE_DIR="${MULANG_SOURCE_DIR:-$(pwd)/src}"
# 上記はmulang自身をmulangでビルドできない段階の暫定コード。
# セルフビルドできるようになったら、以下のコードに置き換える。
#: "$MULANG_SOURCE_DIR"
# MULANG_SOURCE_DIR はmulangでビルド時に定義される。
# 未定義の場合にエラーとする。


if [ ! -d var ]; then
    mkdir -p var
fi

if [ ! -e var/.gitignore ]; then
    echo '*' > var/.gitignore
fi

########################################
# main.sh をチェック

. $MULANG_SOURCE_DIR/check-main.sh

########################################

bash $MULANG_SOURCE_DIR/build-makefile.sh $option >| var/makefile

make --question -f var/makefile $target || make -f var/makefile $target

