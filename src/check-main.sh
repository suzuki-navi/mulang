
if [ ! -e src/main.sh ]; then
    echo "not found: src/main.sh" >&2
    exit 1
fi

option=
if grep "MULANG_SOFT_WORKING_DIR" src/main.sh >/dev/null; then
    # `MULANG_SOFT_WORKING_DIR` という文字列が src/main.sh に含まれる場合
    option="$option --use-soft"
fi
if grep "MULANG_HARD_WORKING_DIR" src/main.sh >/dev/null; then
    # `MULANG_HARD_WORKING_DIR` という文字列が src/main.sh に含まれる場合
    option="$option --use-hard"
fi


